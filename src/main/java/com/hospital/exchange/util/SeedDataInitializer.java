package com.hospital.exchange.util;

import com.hospital.exchange.entity.Hospital;
import com.hospital.exchange.entity.Resource;
import com.hospital.exchange.model.ResourceType;
import com.hospital.exchange.repository.HospitalRepository;
import com.hospital.exchange.repository.ResourceRepository;
import com.hospital.exchange.service.HospitalService;
import com.hospital.exchange.service.ResourceAllocationService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Component
@Order(2)
public class SeedDataInitializer implements CommandLineRunner {

    private final HospitalRepository hospitalRepository;
    private final ResourceRepository resourceRepository;
    private final HospitalService hospitalService;
    private final ResourceAllocationService allocationService;

    public SeedDataInitializer(HospitalRepository hospitalRepository, ResourceRepository resourceRepository,
                               HospitalService hospitalService, ResourceAllocationService allocationService) {
        this.hospitalRepository = hospitalRepository;
        this.resourceRepository = resourceRepository;
        this.hospitalService = hospitalService;
        this.allocationService = allocationService;
    }

    @Override
    public void run(String... args) {
        if (hospitalRepository.count() > 0) {
            return;
        }

        List<Hospital> hospitals = List.of(
                createHospital("AIIMS Delhi", "Ansari Nagar, New Delhi", "+91-11-26588500", "admin@aiims.edu", 50, 28.5672, 77.2100, "hosp1"),
                createHospital("Apollo Chennai", "Greams Road, Chennai", "+91-44-28293333", "reachus@apollo.com", 40, 13.0635, 80.2520, "hosp2"),
                createHospital("Max Mumbai", "Andheri, Mumbai", "+91-22-66487500", "info@maxhealthcare.com", 35, 19.1197, 72.8468, "hosp3"),
                createHospital("Fortis Bangalore", "Bannerghatta Road, Bangalore", "+91-80-66214444", "contact@fortis.com", 30, 12.8954, 77.5992, "hosp4"),
                createHospital("Tata Memorial", "Parel, Mumbai", "+91-22-24177000", "tmh@tmc.gov.in", 45, 18.9977, 72.8413, "hosp5")
        );

        addResource(hospitals.get(0), "ICU Bed-A101", ResourceType.ICU_BED, Resource.ResourceStatus.AVAILABLE);
        addResource(hospitals.get(0), "Ventilator-V01", ResourceType.VENTILATOR, Resource.ResourceStatus.AVAILABLE);
        addResource(hospitals.get(0), "Ambulance-DL01", ResourceType.AMBULANCE, Resource.ResourceStatus.AVAILABLE);
        addResource(hospitals.get(1), "ICU Bed-C201", ResourceType.ICU_BED, Resource.ResourceStatus.AVAILABLE);
        addResource(hospitals.get(1), "Ventilator-C11", ResourceType.VENTILATOR, Resource.ResourceStatus.AVAILABLE);
        addResource(hospitals.get(2), "ICU Bed-M301", ResourceType.ICU_BED, Resource.ResourceStatus.AVAILABLE);
        addResource(hospitals.get(2), "Specialist-Oncologist-1", ResourceType.SPECIALIST, Resource.ResourceStatus.AVAILABLE);
        addResource(hospitals.get(3), "Ambulance-B401", ResourceType.AMBULANCE, Resource.ResourceStatus.AVAILABLE);
        addResource(hospitals.get(3), "Ventilator-B17", ResourceType.VENTILATOR, Resource.ResourceStatus.MAINTENANCE);
        addResource(hospitals.get(4), "ICU Bed-T501", ResourceType.ICU_BED, Resource.ResourceStatus.AVAILABLE);

        allocationService.createRequest(
                hospitals.get(3),
                ResourceType.ICU_BED,
                com.hospital.exchange.entity.AllocationRequest.RequestPriority.HIGH,
                LocalDateTime.now().plusHours(1),
                LocalDateTime.now().plusHours(5)
        );
    }

    private Hospital createHospital(String name, String location, String contactNumber, String contactEmail,
                                    int quota, double latitude, double longitude, String adminUsername) {
        Hospital hospital = Hospital.builder()
                .name(name)
                .location(location)
                .contactNumber(contactNumber)
                .contactEmail(contactEmail)
                .resourceQuota(quota)
                .latitude(latitude)
                .longitude(longitude)
                .build();
        return hospitalService.createHospital(hospital, adminUsername, "hosp123");
    }

    private void addResource(Hospital hospital, String name, ResourceType type, Resource.ResourceStatus status) {
        resourceRepository.save(Resource.builder()
                .resourceName(name)
                .type(type)
                .status(status)
                .hospital(hospital)
                .build());
    }
}
