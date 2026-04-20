package com.hospital.exchange.repository;

import com.hospital.exchange.entity.ResourceSlot;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDateTime;
import java.util.List;

public interface ResourceSlotRepository extends JpaRepository<ResourceSlot, Long> {
    List<ResourceSlot> findByResourceIdAndBookingStatus(Long resourceId, ResourceSlot.SlotStatus status);
    
    // Check for overlaps
    List<ResourceSlot> findByResourceIdAndStartTimeLessThanAndEndTimeGreaterThan(
            Long resourceId, LocalDateTime endTime, LocalDateTime startTime);
}
