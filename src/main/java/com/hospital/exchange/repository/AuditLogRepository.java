package com.hospital.exchange.repository;

import com.hospital.exchange.entity.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {
    List<AuditLog> findByHospitalIdOrderByTimestampDesc(Long hospitalId);
    List<AuditLog> findAllByOrderByTimestampDesc();
}
