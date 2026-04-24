package com.hospital.exchange.util;

import com.hospital.exchange.entity.Hospital;
import com.hospital.exchange.entity.Role;
import com.hospital.exchange.entity.User;
import com.hospital.exchange.repository.HospitalRepository;
import com.hospital.exchange.repository.RoleRepository;
import com.hospital.exchange.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Component
@Order(1)
public class UserInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final HospitalRepository hospitalRepository;
    private final PasswordEncoder passwordEncoder;

    public UserInitializer(UserRepository userRepository, RoleRepository roleRepository,
                           HospitalRepository hospitalRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.hospitalRepository = hospitalRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        // 1. Create Roles if not exist
        if (roleRepository.findByName("ADMIN").isEmpty()) {
            roleRepository.save(new Role(null, "ADMIN"));
        }
        if (roleRepository.findByName("HOSPITAL_ADMIN").isEmpty()) {
            roleRepository.save(new Role(null, "HOSPITAL_ADMIN"));
        }

        // 2. Create Default Admin if not exist
        if (userRepository.findByUsername("admin").isEmpty()) {
            Role adminRole = roleRepository.findByName("ADMIN").get();
            Set<Role> roles = new HashSet<>();
            roles.add(adminRole);

            User admin = User.builder()
                    .username("admin")
                    .password(passwordEncoder.encode("admin123"))
                    .enabled(true)
                    .roles(roles)
                    .build();

            userRepository.save(admin);
            System.out.println("Default admin user created: admin/admin123");
        }

        // 3. Create demo hospital admins for the first hospitals in the system
        Role hospitalAdminRole = roleRepository.findByName("HOSPITAL_ADMIN").orElse(null);
        if (hospitalAdminRole != null) {
            List<Hospital> hospitals = hospitalRepository.findAll().stream()
                    .sorted(Comparator.comparing(Hospital::getId))
                    .limit(5)
                    .toList();

            for (int i = 0; i < hospitals.size(); i++) {
                Hospital hospital = hospitals.get(i);
                String username = "hosp" + (i + 1);
                Set<Role> roles = new HashSet<>();
                roles.add(hospitalAdminRole);
                boolean existed = userRepository.findByUsername(username).isPresent();

                User hospitalAdmin = userRepository.findByUsername(username).orElseGet(() -> User.builder()
                        .username(username)
                        .build());

                hospitalAdmin.setPassword(passwordEncoder.encode("hosp123"));
                hospitalAdmin.setEnabled(true);
                hospitalAdmin.setHospital(hospital);
                hospitalAdmin.setRoles(roles);

                userRepository.save(hospitalAdmin);
                if (existed) {
                    System.out.println("Hospital admin synchronized: " + username + "/hosp123");
                } else {
                    System.out.println("Hospital admin created: " + username + "/hosp123");
                }
            }
        }
    }
}
