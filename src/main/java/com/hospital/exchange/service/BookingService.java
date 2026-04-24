package com.hospital.exchange.service;

import com.hospital.exchange.entity.Booking;
import com.hospital.exchange.entity.Resource;
import com.hospital.exchange.entity.ResourceSlot;
import com.hospital.exchange.exception.ResourceNotFoundException;
import com.hospital.exchange.repository.BookingRepository;
import com.hospital.exchange.repository.ResourceRepository;
import com.hospital.exchange.repository.ResourceSlotRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class BookingService {

    private final ResourceSlotRepository slotRepository;
    private final BookingRepository bookingRepository;
    private final ResourceRepository resourceRepository;
    private final NotificationService notificationService;
    private final ResourceAllocationService allocationService;

    public BookingService(ResourceSlotRepository slotRepository, BookingRepository bookingRepository,
                          ResourceRepository resourceRepository, NotificationService notificationService,
                          ResourceAllocationService allocationService) {
        this.slotRepository = slotRepository;
        this.bookingRepository = bookingRepository;
        this.resourceRepository = resourceRepository;
        this.notificationService = notificationService;
        this.allocationService = allocationService;
    }

    @Transactional
    public ResourceSlot createSlot(Resource resource, LocalDateTime start, LocalDateTime end) {
        // Check for overlaps
        List<ResourceSlot> overlaps = slotRepository.findByResourceIdAndStartTimeLessThanAndEndTimeGreaterThan(
                resource.getId(), end, start);
        
        if (!overlaps.isEmpty()) {
            throw new RuntimeException("Slot overlap detected for resource: " + resource.getResourceName());
        }

        ResourceSlot slot = ResourceSlot.builder()
                .resource(resource)
                .startTime(start)
                .endTime(end)
                .bookingStatus(ResourceSlot.SlotStatus.OPEN)
                .build();
        
        return slotRepository.save(slot);
    }

    @Transactional
    public void bookSlot(Long slotId) {
        ResourceSlot slot = slotRepository.findById(slotId)
                .orElseThrow(() -> new RuntimeException("Slot not found"));
        
        if (slot.getBookingStatus() != ResourceSlot.SlotStatus.OPEN) {
            throw new RuntimeException("Slot is not available for booking");
        }

        slot.setBookingStatus(ResourceSlot.SlotStatus.BOOKED);
        slotRepository.save(slot);
    }

    public List<Booking> getAllBookings() {
        return bookingRepository.findAll();
    }

    @Transactional
    public void releaseBooking(Long bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking " + bookingId + " was not found."));

        if (booking.isReleased()) {
            return;
        }

        Resource resource = booking.getResource();
        resource.setStatus(Resource.ResourceStatus.AVAILABLE);
        resourceRepository.save(resource);

        booking.setReleased(true);
        bookingRepository.save(booking);

        notificationService.notifyResourceUpdate(resource.getId(), Resource.ResourceStatus.AVAILABLE.name());
        allocationService.processWaitingRequests();
    }
}
