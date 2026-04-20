package com.hospital.exchange.service;

import com.hospital.exchange.entity.AuditLog;
import com.hospital.exchange.repository.AuditLogRepository;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class AuditLogService {
    private final AuditLogRepository auditLogRepository;

    public AuditLogService(AuditLogRepository auditLogRepository) {
        this.auditLogRepository = auditLogRepository;
    }

    public List<AuditLog> getAllLogs() {
        return auditLogRepository.findAllByOrderByTimestampDesc();
    }

    public List<AuditLog> getLogsByHospital(Long hospitalId) {
        return auditLogRepository.findByHospitalIdOrderByTimestampDesc(hospitalId);
    }
}
