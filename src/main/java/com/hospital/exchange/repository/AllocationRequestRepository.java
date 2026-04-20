package com.hospital.exchange.repository;

import com.hospital.exchange.entity.AllocationRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AllocationRequestRepository extends JpaRepository<AllocationRequest, Long> {
    List<AllocationRequest> findByStatusOrderByPriorityDescRequestedAtAsc(AllocationRequest.RequestStatus status);
    List<AllocationRequest> findByRequesterHospitalId(Long hospitalId);
}
