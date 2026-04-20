package com.hospital.exchange.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Data Transfer Object for aggregated hospital resource status.
 * Used for optimizing performance in Map and Dashboard views.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HospitalResourceSummaryDTO {
    private int icuTotal;
    private int icuAvail;
    private int ventTotal;
    private int ventAvail;
    private int ambulanceTotal;
    private int ambulanceAvail;
    private int specialistTotal;
    private int specialistAvail;
    
    private String status; // AVAILABLE, LIMITED, CRITICAL
    private int totalAvail;
    private int totalAll;
    private double availabilityRatio;

    /**
     * Factory method to calculate summary logic consistently across the system.
     */
    public static HospitalResourceSummaryDTO calculate(int icuT, int icuA, int ventT, int ventA, 
                                                      int ambT, int ambA, int specT, int specA) {
        int totalA = icuA + ventA + ambA + specA;
        int totalSum = icuT + ventT + ambT + specT;
        double ratio = totalSum > 0 ? (double) totalA / totalSum : 0;
        
        String calculatedStatus = "CRITICAL";
        if (totalSum > 0) {
            if (ratio >= 0.5) calculatedStatus = "AVAILABLE";
            else if (ratio > 0) calculatedStatus = "LIMITED";
        }

        return HospitalResourceSummaryDTO.builder()
                .icuTotal(icuT).icuAvail(icuA)
                .ventTotal(ventT).ventAvail(ventA)
                .ambulanceTotal(ambT).ambulanceAvail(ambA)
                .specialistTotal(specT).specialistAvail(specA)
                .totalAvail(totalA)
                .totalAll(totalSum)
                .availabilityRatio(ratio)
                .status(calculatedStatus)
                .build();
    }
}
