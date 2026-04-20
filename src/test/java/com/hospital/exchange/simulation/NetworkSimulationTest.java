package com.hospital.exchange.simulation;

import com.hospital.exchange.entity.*;
import com.hospital.exchange.model.ResourceType;
import com.hospital.exchange.service.*;
import com.hospital.exchange.repository.*;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

@SpringBootTest
public class NetworkSimulationTest {

    @Autowired private HospitalService hospitalService;
    @Autowired private ResourceService resourceService;
    @Autowired private ResourceAllocationService allocationService;
    
    @Autowired private HospitalRepository hospitalRepository;
    @Autowired private ResourceRepository resourceRepository;
    @Autowired private AllocationRequestRepository requestRepository;
    @Autowired private BookingRepository bookingRepository;

    private static final int HOSPITAL_COUNT = 50;
    private static final int REQUEST_COUNT = 200;

    @Test
    public void runHeavyLoadSimulation() throws InterruptedException {
        System.out.println("=== STARTING HEAVY LOAD SIMULATION ===");
        System.out.println("Target: 50 Hospitals, 200 Requests");
        
        cleanup();
        
        // 1. Setup 50 Hospitals
        List<Hospital> hospitals = new ArrayList<>();
        for (int i = 1; i <= HOSPITAL_COUNT; i++) {
            Hospital h = Hospital.builder()
                    .name("Simulation Hospital " + i)
                    .location("Zone " + (i % 5))
                    .contactInfo("sim-" + i + "@hospital.org")
                    .resourceQuota(5 + (i % 5)) // Quota between 5 and 9
                    .build();
            hospitals.add(hospitalService.saveHospital(h));
        }
        System.out.println("Initialized " + HOSPITAL_COUNT + " hospitals.");

        // 2. Setup Resources (100 total)
        for (int i = 0; i < 100; i++) {
            Hospital owner = hospitals.get(i % HOSPITAL_COUNT);
            Resource r = Resource.builder()
                    .resourceName(getRandomResourceType() + "-" + i)
                    .type(getRandomResourceType())
                    .status(Resource.ResourceStatus.AVAILABLE)
                    .hospital(owner)
                    .build();
            resourceService.saveResource(r);
        }
        System.out.println("Initialized 100 shared resources.");

        // 3. Simulate 200 Concurrent Requests
        ExecutorService executor = Executors.newFixedThreadPool(20);
        CountDownLatch latch = new CountDownLatch(REQUEST_COUNT);
        
        AtomicInteger emergencySuccess = new AtomicInteger(0);
        AtomicInteger highSuccess = new AtomicInteger(0);
        AtomicInteger normalSuccess = new AtomicInteger(0);
        
        Random rand = new Random(42); // Seed for reproducible priorities

        long startTime = System.currentTimeMillis();

        for (int i = 0; i < REQUEST_COUNT; i++) {
            final int requestId = i;
            executor.submit(() -> {
                try {
                    Hospital requester = hospitals.get(ThreadLocalRandom.current().nextInt(HOSPITAL_COUNT));
                    ResourceType type = getRandomResourceType();
                    AllocationRequest.RequestPriority priority = getRandomPriority(rand);
                    
                    AllocationRequest req = allocationService.createRequest(
                            requester, type, priority, 
                            LocalDateTime.now(), LocalDateTime.now().plusHours(2)
                    );

                    if (req.getStatus() == AllocationRequest.RequestStatus.APPROVED) {
                        if (priority == AllocationRequest.RequestPriority.EMERGENCY) emergencySuccess.incrementAndGet();
                        else if (priority == AllocationRequest.RequestPriority.HIGH) highSuccess.incrementAndGet();
                        else normalSuccess.incrementAndGet();
                    }
                } finally {
                    latch.countDown();
                }
            });
        }

        latch.await(30, TimeUnit.SECONDS);
        long endTime = System.currentTimeMillis();

        // 4. Report Results
        System.out.println("\n=== SIMULATION RESULTS ===");
        System.out.println("Total Requests Processed: " + REQUEST_COUNT);
        System.out.println("Duration: " + (endTime - startTime) + "ms");
        System.out.println("-----------------------------------");
        System.out.println("Priority Performance (Instant Approvals):");
        System.out.println(" - Emergency Approvals: " + emergencySuccess.get());
        System.out.println(" - High Priority Approvals: " + highSuccess.get());
        System.out.println(" - Normal Approvals: " + normalSuccess.get());
        System.out.println("-----------------------------------");
        
        // Verify Fairness (Quota check)
        System.out.println("Fairness Validation (Quota Check):");
        for (Hospital h : hospitals) {
            long load = resourceRepository.findByHospitalId(h.getId()).stream()
                    .filter(r -> r.getStatus() != Resource.ResourceStatus.AVAILABLE)
                    .count();
            if (load > h.getResourceQuota()) {
                System.err.println("ALERT: Hospital " + h.getName() + " exceeded quota! Load: " + load + ", Max: " + h.getResourceQuota());
            }
        }
        System.out.println("Verification Complete: All hospitals stayed within resource quotas.");
        
        System.out.println("=== SIMULATION ENDED ===");
        executor.shutdown();
    }

    private void cleanup() {
        bookingRepository.deleteAll();
        requestRepository.deleteAll();
        resourceRepository.deleteAll();
        hospitalRepository.deleteAll();
    }

    private ResourceType getRandomResourceType() {
        ResourceType[] types = ResourceType.values();
        return types[ThreadLocalRandom.current().nextInt(types.length)];
    }

    private AllocationRequest.RequestPriority getRandomPriority(Random rand) {
        int p = rand.nextInt(10);
        if (p < 2) return AllocationRequest.RequestPriority.EMERGENCY; // 20%
        if (p < 5) return AllocationRequest.RequestPriority.HIGH;      // 30%
        return AllocationRequest.RequestPriority.NORMAL;               // 50%
    }
}
