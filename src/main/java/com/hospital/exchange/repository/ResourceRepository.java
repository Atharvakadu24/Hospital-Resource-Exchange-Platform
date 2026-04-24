package com.hospital.exchange.repository;

import com.hospital.exchange.entity.Resource;
import com.hospital.exchange.model.ResourceType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;

public interface ResourceRepository extends JpaRepository<Resource, Long> {
    List<Resource> findByTypeAndStatus(ResourceType type, Resource.ResourceStatus status);
    List<Resource> findByTypeAndStatusIn(ResourceType type, Collection<Resource.ResourceStatus> statuses);
    List<Resource> findByHospitalId(Long hospitalId);
}
