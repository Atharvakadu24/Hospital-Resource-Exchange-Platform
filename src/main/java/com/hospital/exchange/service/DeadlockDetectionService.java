package com.hospital.exchange.service;

import org.springframework.stereotype.Service;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Service to simulate and detect deadlocks using a Wait-for Graph.
 */
@Service
public class DeadlockDetectionService {

    private final Map<Long, Set<Long>> waitForGraph = new ConcurrentHashMap<>();

    public Map<Long, Set<Long>> getWaitForGraph() {
        return Collections.unmodifiableMap(waitForGraph);
    }

    /**
     * Adds a dependency: Hospital A is now waiting for a resource held by Hospital B.
     * Before adding, it checks if this would create a cycle.
     */
    public synchronized boolean wouldCreateDeadlock(Long waitingHospitalId, Long holdingHospitalId) {
        if (waitingHospitalId.equals(holdingHospitalId)) return false;

        // Temporarily add edge to check for cycle
        waitForGraph.computeIfAbsent(waitingHospitalId, k -> new HashSet<>()).add(holdingHospitalId);
        
        if (hasCycle(waitingHospitalId)) {
            // Remove it immediately since it's a deadlock
            waitForGraph.get(waitingHospitalId).remove(holdingHospitalId);
            return true;
        }
        
        // Edge stays if it's NOT a deadlock (Pre-registration)
        return false;
    }

    public synchronized void addDependency(Long waitingHospitalId, Long holdingHospitalId) {
        waitForGraph.computeIfAbsent(waitingHospitalId, k -> new HashSet<>()).add(holdingHospitalId);
    }

    public synchronized void removeDependency(Long waitingHospitalId, Long holdingHospitalId) {
        Set<Long> dependencies = waitForGraph.get(waitingHospitalId);
        if (dependencies != null) {
            dependencies.remove(holdingHospitalId);
            if (dependencies.isEmpty()) {
                waitForGraph.remove(waitingHospitalId);
            }
        }
    }

    public synchronized void clearAllDependencies(Long hospitalId) {
        waitForGraph.remove(hospitalId);
        System.out.println("CLEANUP: Removed all waiting dependencies for hospital " + hospitalId);
    }

    private boolean hasCycle(Long startNode) {
        Set<Long> visited = new HashSet<>();
        Set<Long> recStack = new HashSet<>();
        return isCyclicUtil(startNode, visited, recStack);
    }

    private boolean isCyclicUtil(Long node, Set<Long> visited, Set<Long> recStack) {
        if (recStack.contains(node)) return true;
        if (visited.contains(node)) return false;

        visited.add(node);
        recStack.add(node);

        Set<Long> children = waitForGraph.get(node);
        if (children != null) {
            for (Long child : children) {
                if (isCyclicUtil(child, visited, recStack)) return true;
            }
        }

        recStack.remove(node);
        return false;
    }
    
    /**
     * Resolves a deadlock by removing a hospital's waiting edge.
     */
    public synchronized void resolveDeadlock(Long waitingHospitalId) {
        waitForGraph.remove(waitingHospitalId);
        System.out.println("RESOLVED: Removed all wait dependencies for hospital " + waitingHospitalId);
    }

    public synchronized String getGraphSnapshot() {
        StringBuilder sb = new StringBuilder("Current Wait-for Graph: ");
        waitForGraph.forEach((host, deps) -> {
            sb.append("\nHospital ").append(host).append(" -> ").append(deps);
        });
        return sb.toString();
    }
}
