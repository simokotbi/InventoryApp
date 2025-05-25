"""
Sync Manager for Hybrid Data Synchronization

Manages synchronization between local SQLite database and Supabase backend.
Handles pull/push logic, conflict resolution, and offline-to-online synchronization.
"""
from typing import List, Dict, Any, Optional, Union
import asyncio
from datetime import datetime, timezone
from dataclasses import dataclass
from enum import Enum

from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from loguru import logger

from local_db.local_db_manager import LocalDbManager
from local_db.models import User, Product, Customer, Sale, SaleItem, InventoryItem, InventoryMovement
from api_client.auth_api_client import AuthApiClient
from api_client.product_api_client import ProductApiClient
from api_client.customer_api_client import CustomerApiClient
from api_client.sales_api_client import SalesApiClient
from api_client.inventory_api_client import InventoryApiClient


class SyncAction(Enum):
    """Enumeration of sync actions"""
    CREATE = "create"
    UPDATE = "update"
    DELETE = "delete"


class ConflictResolution(Enum):
    """Conflict resolution strategies"""
    LOCAL_WINS = "local_wins"
    REMOTE_WINS = "remote_wins"
    LAST_WRITE_WINS = "last_write_wins"
    MANUAL_RESOLUTION = "manual_resolution"


@dataclass
class SyncResult:
    """Result of a sync operation"""
    success: bool
    synced_count: int
    failed_count: int
    conflicts_count: int
    errors: List[str]
    details: Dict[str, Any]


@dataclass
class ConflictRecord:
    """Represents a sync conflict"""
    table_name: str
    local_record: Dict[str, Any]
    remote_record: Dict[str, Any]
    conflict_field: str
    local_timestamp: datetime
    remote_timestamp: datetime


class SyncManager:
    """
    Manages synchronization between local SQLite and Supabase backend.
    
    Features:
    - Bidirectional sync (pull from remote, push local changes)
    - Conflict resolution strategies
    - Batch operations for performance
    - Sync status tracking
    - Offline-to-online synchronization
    """

    def __init__(
        self,
        local_db_manager: LocalDbManager,
        auth_client: AuthApiClient,
        product_client: ProductApiClient,
        customer_client: CustomerApiClient,
        sales_client: SalesApiClient,
        inventory_client: InventoryApiClient,
        conflict_resolution: ConflictResolution = ConflictResolution.LAST_WRITE_WINS
    ):
        self.local_db = local_db_manager
        self.auth_client = auth_client
        self.product_client = product_client
        self.customer_client = customer_client
        self.sales_client = sales_client
        self.inventory_client = inventory_client
        self.conflict_resolution = conflict_resolution
        
        # Mapping of model classes to their respective API clients
        self.model_client_mapping = {
            Product: self.product_client,
            Customer: self.customer_client,
            Sale: self.sales_client,
            # SaleItem: self.sales_client,  # Handled through Sale
            InventoryItem: self.inventory_client,
            InventoryMovement: self.inventory_client,
        }
        
        self.last_sync_timestamp: Optional[datetime] = None
        self.sync_in_progress = False

    async def full_sync(self) -> SyncResult:
        """
        Perform a full bidirectional synchronization.
        
        Steps:
        1. Pull latest data from remote
        2. Push pending local changes
        3. Resolve conflicts
        4. Update sync timestamps
        
        Returns:
            SyncResult: Summary of sync operation
        """
        if self.sync_in_progress:
            logger.warning("Sync already in progress, skipping")
            return SyncResult(
                success=False,
                synced_count=0,
                failed_count=0,
                conflicts_count=0,
                errors=["Sync already in progress"],
                details={}
            )

        logger.info("Starting full synchronization")
        self.sync_in_progress = True
        
        try:
            # Step 1: Pull remote changes
            pull_result = await self.pull_remote_changes()
            
            # Step 2: Push local changes
            push_result = await self.push_local_changes()
            
            # Combine results
            total_synced = pull_result.synced_count + push_result.synced_count
            total_failed = pull_result.failed_count + push_result.failed_count
            total_conflicts = pull_result.conflicts_count + push_result.conflicts_count
            all_errors = pull_result.errors + push_result.errors
            
            # Update last sync timestamp
            self.last_sync_timestamp = datetime.now(timezone.utc)
            
            success = total_failed == 0 and total_conflicts == 0
            
            logger.info(
                f"Full sync completed. Synced: {total_synced}, "
                f"Failed: {total_failed}, Conflicts: {total_conflicts}"
            )
            
            return SyncResult(
                success=success,
                synced_count=total_synced,
                failed_count=total_failed,
                conflicts_count=total_conflicts,
                errors=all_errors,
                details={
                    "pull_result": pull_result,
                    "push_result": push_result,
                    "sync_timestamp": self.last_sync_timestamp
                }
            )
            
        except Exception as e:
            logger.error(f"Full sync failed with error: {e}")
            return SyncResult(
                success=False,
                synced_count=0,
                failed_count=0,
                conflicts_count=0,
                errors=[str(e)],
                details={}
            )
        finally:
            self.sync_in_progress = False

    async def pull_remote_changes(self) -> SyncResult:
        """
        Pull changes from remote Supabase backend to local database.
        
        Returns:
            SyncResult: Summary of pull operation
        """
        logger.info("Pulling remote changes")
        synced_count = 0
        failed_count = 0
        conflicts_count = 0
        errors = []
        
        try:
            with self.local_db.get_session() as session:
                # Pull data for each model type
                for model_class, api_client in self.model_client_mapping.items():
                    try:
                        # Get remote data
                        remote_data = await self._fetch_remote_data(api_client, model_class)
                        
                        if not remote_data:
                            continue
                        
                        # Process each remote record
                        for remote_record in remote_data:
                            try:
                                result = await self._process_remote_record(
                                    session, model_class, remote_record
                                )
                                
                                if result == "synced":
                                    synced_count += 1
                                elif result == "conflict":
                                    conflicts_count += 1
                                elif result == "failed":
                                    failed_count += 1
                                    
                            except Exception as e:
                                logger.error(f"Failed to process remote record: {e}")
                                failed_count += 1
                                errors.append(str(e))
                        
                        session.commit()
                        
                    except Exception as e:
                        logger.error(f"Failed to pull {model_class.__name__} data: {e}")
                        session.rollback()
                        failed_count += 1
                        errors.append(f"{model_class.__name__}: {str(e)}")
                        
        except Exception as e:
            logger.error(f"Pull operation failed: {e}")
            failed_count += 1
            errors.append(str(e))
        
        logger.info(f"Pull completed. Synced: {synced_count}, Failed: {failed_count}, Conflicts: {conflicts_count}")
        
        return SyncResult(
            success=failed_count == 0 and conflicts_count == 0,
            synced_count=synced_count,
            failed_count=failed_count,
            conflicts_count=conflicts_count,
            errors=errors,
            details={}
        )

    async def push_local_changes(self) -> SyncResult:
        """
        Push pending local changes to remote Supabase backend.
        
        Returns:
            SyncResult: Summary of push operation
        """
        logger.info("Pushing local changes")
        synced_count = 0
        failed_count = 0
        conflicts_count = 0
        errors = []
        
        try:
            with self.local_db.get_session() as session:
                # Push changes for each model type
                for model_class, api_client in self.model_client_mapping.items():
                    try:
                        # Get unsynced local records
                        unsynced_records = session.query(model_class).filter(
                            model_class.is_synced == False
                        ).all()
                        
                        if not unsynced_records:
                            continue
                        
                        # Process each unsynced record
                        for local_record in unsynced_records:
                            try:
                                result = await self._push_local_record(
                                    session, api_client, local_record
                                )
                                
                                if result == "synced":
                                    synced_count += 1
                                elif result == "conflict":
                                    conflicts_count += 1
                                elif result == "failed":
                                    failed_count += 1
                                    
                            except Exception as e:
                                logger.error(f"Failed to push local record: {e}")
                                failed_count += 1
                                errors.append(str(e))
                        
                        session.commit()
                        
                    except Exception as e:
                        logger.error(f"Failed to push {model_class.__name__} data: {e}")
                        session.rollback()
                        failed_count += 1
                        errors.append(f"{model_class.__name__}: {str(e)}")
                        
        except Exception as e:
            logger.error(f"Push operation failed: {e}")
            failed_count += 1
            errors.append(str(e))
        
        logger.info(f"Push completed. Synced: {synced_count}, Failed: {failed_count}, Conflicts: {conflicts_count}")
        
        return SyncResult(
            success=failed_count == 0 and conflicts_count == 0,
            synced_count=synced_count,
            failed_count=failed_count,
            conflicts_count=conflicts_count,
            errors=errors,
            details={}
        )

    async def _fetch_remote_data(self, api_client, model_class) -> List[Dict[str, Any]]:
        """Fetch remote data for a specific model class"""
        try:
            if hasattr(api_client, 'get_all'):
                response = await api_client.get_all()
                if response.get('success'):
                    return response.get('data', [])
            return []
        except Exception as e:
            logger.error(f"Failed to fetch remote data for {model_class.__name__}: {e}")
            return []

    async def _process_remote_record(
        self, 
        session: Session, 
        model_class, 
        remote_record: Dict[str, Any]
    ) -> str:
        """
        Process a single remote record.
        
        Returns:
            str: "synced", "conflict", or "failed"
        """
        try:
            remote_id = remote_record.get('id')
            if not remote_id:
                return "failed"
            
            # Check if record exists locally
            local_record = session.query(model_class).filter(
                model_class.id == remote_id
            ).first()
            
            if not local_record:
                # Create new local record
                new_record = model_class(**remote_record)
                new_record.is_synced = True
                new_record.last_synced_at = datetime.now(timezone.utc)
                session.add(new_record)
                return "synced"
            
            else:
                # Check for conflicts
                remote_updated = remote_record.get('updated_at')
                local_updated = local_record.updated_at
                
                if remote_updated and local_updated:
                    remote_dt = datetime.fromisoformat(remote_updated.replace('Z', '+00:00'))
                    
                    # Check if local record has pending changes
                    if not local_record.is_synced:
                        # Conflict: both local and remote have changes
                        if self.conflict_resolution == ConflictResolution.LAST_WRITE_WINS:
                            if remote_dt > local_updated:
                                # Remote wins
                                self._update_local_from_remote(local_record, remote_record)
                                local_record.is_synced = True
                                local_record.last_synced_at = datetime.now(timezone.utc)
                                return "synced"
                            else:
                                # Local wins, keep local changes
                                return "conflict"
                        else:
                            return "conflict"
                    
                    elif remote_dt > local_record.last_synced_at:
                        # Remote is newer, update local
                        self._update_local_from_remote(local_record, remote_record)
                        local_record.is_synced = True
                        local_record.last_synced_at = datetime.now(timezone.utc)
                        return "synced"
                
                return "synced"  # No update needed
                
        except Exception as e:
            logger.error(f"Failed to process remote record: {e}")
            return "failed"

    async def _push_local_record(
        self, 
        session: Session, 
        api_client, 
        local_record
    ) -> str:
        """
        Push a single local record to remote.
        
        Returns:
            str: "synced", "conflict", or "failed"
        """
        try:
            action = local_record.action_pending
            
            if action == SyncAction.CREATE.value:
                response = await api_client.create(local_record.to_dict())
                
            elif action == SyncAction.UPDATE.value:
                response = await api_client.update(local_record.id, local_record.to_dict())
                
            elif action == SyncAction.DELETE.value:
                response = await api_client.delete(local_record.id)
                
            else:
                return "failed"
            
            if response.get('success'):
                # Mark as synced
                local_record.is_synced = True
                local_record.action_pending = None
                local_record.last_synced_at = datetime.now(timezone.utc)
                
                # Update with remote data if available
                remote_data = response.get('data')
                if remote_data:
                    self._update_local_from_remote(local_record, remote_data)
                
                return "synced"
            else:
                return "failed"
                
        except Exception as e:
            logger.error(f"Failed to push local record: {e}")
            return "failed"

    def _update_local_from_remote(self, local_record, remote_data: Dict[str, Any]):
        """Update local record with remote data"""
        try:
            for key, value in remote_data.items():
                if hasattr(local_record, key) and key not in ['id', 'created_at']:
                    setattr(local_record, key, value)
        except Exception as e:
            logger.error(f"Failed to update local record from remote: {e}")

    async def sync_single_record(
        self, 
        model_class, 
        record_id: Union[int, str], 
        direction: str = "bidirectional"
    ) -> SyncResult:
        """
        Synchronize a single record.
        
        Args:
            model_class: The model class to sync
            record_id: ID of the record to sync
            direction: "pull", "push", or "bidirectional"
            
        Returns:
            SyncResult: Summary of sync operation
        """
        logger.info(f"Syncing single {model_class.__name__} record: {record_id}")
        
        try:
            api_client = self.model_client_mapping.get(model_class)
            if not api_client:
                return SyncResult(
                    success=False,
                    synced_count=0,
                    failed_count=1,
                    conflicts_count=0,
                    errors=[f"No API client for {model_class.__name__}"],
                    details={}
                )
            
            with self.local_db.get_session() as session:
                if direction in ["pull", "bidirectional"]:
                    # Pull from remote
                    remote_data = await api_client.get_by_id(record_id)
                    if remote_data.get('success'):
                        result = await self._process_remote_record(
                            session, model_class, remote_data['data']
                        )
                        session.commit()
                
                if direction in ["push", "bidirectional"]:
                    # Push to remote
                    local_record = session.query(model_class).filter(
                        model_class.id == record_id
                    ).first()
                    
                    if local_record and not local_record.is_synced:
                        result = await self._push_local_record(
                            session, api_client, local_record
                        )
                        session.commit()
            
            return SyncResult(
                success=True,
                synced_count=1,
                failed_count=0,
                conflicts_count=0,
                errors=[],
                details={"record_id": record_id, "direction": direction}
            )
            
        except Exception as e:
            logger.error(f"Failed to sync single record: {e}")
            return SyncResult(
                success=False,
                synced_count=0,
                failed_count=1,
                conflicts_count=0,
                errors=[str(e)],
                details={}
            )

    def get_sync_status(self) -> Dict[str, Any]:
        """
        Get current synchronization status.
        
        Returns:
            Dict containing sync status information
        """
        try:
            with self.local_db.get_session() as session:
                status = {
                    "last_sync": self.last_sync_timestamp.isoformat() if self.last_sync_timestamp else None,
                    "sync_in_progress": self.sync_in_progress,
                    "pending_changes": {}
                }
                
                # Count pending changes for each model
                for model_class in self.model_client_mapping.keys():
                    unsynced_count = session.query(model_class).filter(
                        model_class.is_synced == False
                    ).count()
                    
                    status["pending_changes"][model_class.__name__] = unsynced_count
                
                return status
                
        except Exception as e:
            logger.error(f"Failed to get sync status: {e}")
            return {
                "last_sync": None,
                "sync_in_progress": False,
                "pending_changes": {},
                "error": str(e)
            }

    def reset_sync_state(self) -> bool:
        """
        Reset synchronization state (mark all records as unsynced).
        Use with caution - typically for debugging or fresh sync.
        
        Returns:
            bool: True if successful
        """
        try:
            with self.local_db.get_session() as session:
                for model_class in self.model_client_mapping.keys():
                    session.query(model_class).update({
                        model_class.is_synced: False,
                        model_class.last_synced_at: None
                    })
                
                session.commit()
                self.last_sync_timestamp = None
                logger.info("Sync state reset successfully")
                return True
                
        except Exception as e:
            logger.error(f"Failed to reset sync state: {e}")
            return False
