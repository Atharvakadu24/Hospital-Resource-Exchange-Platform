package com.hospital.exchange.service;

import com.hospital.exchange.entity.Hospital;
import com.hospital.exchange.entity.Resource;
import com.hospital.exchange.entity.Role;
import com.hospital.exchange.entity.User;
import com.hospital.exchange.exception.ResourceNotFoundException;
import com.hospital.exchange.repository.AllocationRequestRepository;
import com.hospital.exchange.repository.AuditLogRepository;
import com.hospital.exchange.repository.BookingRepository;
import com.hospital.exchange.repository.HospitalRepository;
import com.hospital.exchange.repository.ResourceRepository;
import com.hospital.exchange.repository.RoleRepository;
import com.hospital.exchange.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
public class HospitalService {
    private final HospitalRepository hospitalRepository;
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final ResourceRepository resourceRepository;
    private final AllocationRequestRepository allocationRequestRepository;
    private final BookingRepository bookingRepository;
    private final AuditLogRepository auditLogRepository;
    private final PasswordEncoder passwordEncoder;

    public HospitalService(HospitalRepository hospitalRepository, UserRepository userRepository, RoleRepository roleRepository,
                           ResourceRepository resourceRepository, AllocationRequestRepository allocationRequestRepository,
                           BookingRepository bookingRepository, AuditLogRepository auditLogRepository,
                           PasswordEncoder passwordEncoder) {
        this.hospitalRepository = hospitalRepository;
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.resourceRepository = resourceRepository;
        this.allocationRequestRepository = allocationRequestRepository;
        this.bookingRepository = bookingRepository;
        this.auditLogRepository = auditLogRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public List<Hospital> getAllHospitals() {
        return hospitalRepository.findAll();
    }

    public Hospital getHospitalById(Long id) {
        return hospitalRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Hospital " + id + " was not found."));
    }

    public Hospital saveHospital(Hospital hospital) {
        return hospitalRepository.save(hospital);
    }

    @Transactional
    public Hospital createHospital(Hospital hospital, String adminUsername, String adminPassword) {
        Hospital savedHospital = hospitalRepository.save(hospital);

        if (adminUsername != null && !adminUsername.isBlank() && adminPassword != null && !adminPassword.isBlank()) {
            Role hospitalAdminRole = roleRepository.findByName("HOSPITAL_ADMIN")
                    .orElseThrow(() -> new ResourceNotFoundException("Hospital admin role is missing."));

            Set<Role> roles = new HashSet<>();
            roles.add(hospitalAdminRole);

            User hospitalAdmin = userRepository.findByUsername(adminUsername).orElseGet(User::new);
            hospitalAdmin.setUsername(adminUsername);
            hospitalAdmin.setPassword(passwordEncoder.encode(adminPassword));
            hospitalAdmin.setEnabled(true);
            hospitalAdmin.setHospital(savedHospital);
            hospitalAdmin.setRoles(roles);
            userRepository.save(hospitalAdmin);
        }

        logAudit("HOSPITAL_CREATED", "Created hospital " + savedHospital.getName(), "Admin", savedHospital);
        return savedHospital;
    }

    @Transactional
    public void deleteHospital(Long hospitalId) {
        Hospital hospital = getHospitalById(hospitalId);

        bookingRepository.findAll().stream()
                .filter(booking -> booking.getResource().getHospital().getId().equals(hospitalId)
                        || booking.getRequest().getRequesterHospital().getId().equals(hospitalId))
                .sorted(Comparator.comparing(booking -> booking.getId(), Comparator.reverseOrder()))
                .forEach(bookingRepository::delete);

        allocationRequestRepository.findByRequesterHospitalId(hospitalId)
                .forEach(allocationRequestRepository::delete);

        resourceRepository.findByHospitalId(hospitalId)
                .forEach(resourceRepository::delete);

        userRepository.findByHospitalId(hospitalId).forEach(user -> {
            user.setHospital(null);
            userRepository.save(user);
        });

        auditLogRepository.deleteAll(auditLogRepository.findByHospitalIdOrderByTimestampDesc(hospitalId));
        hospitalRepository.delete(hospital);
        logAudit("HOSPITAL_DELETED", "Deleted hospital " + hospital.getName(), "Admin", null);
    }

    private void logAudit(String action, String details, String performedBy, Hospital hospital) {
        auditLogRepository.save(com.hospital.exchange.entity.AuditLog.builder()
                .action(action)
                .details(details)
                .performedBy(performedBy)
                .timestamp(LocalDateTime.now())
                .hospital(hospital)
                .build());
    }
}
