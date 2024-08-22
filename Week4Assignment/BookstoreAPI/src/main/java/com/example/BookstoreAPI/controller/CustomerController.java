package com.example.BookstoreAPI.controller;
import com.example.BookstoreAPI.model.Customer;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/customers")
public class CustomerController {

    private List<Customer> customers = new ArrayList<>();

    // POST method to create a new customer from JSON request body
    @PostMapping
    public ResponseEntity<Customer> createCustomer(@RequestBody Customer customer) {
        customers.add(customer);
        return new ResponseEntity<>(customer, HttpStatus.CREATED);
    }

    // POST method to process form data for customer registration
    @PostMapping("/register")
    public ResponseEntity<Customer> registerCustomer(
            @RequestParam("name") String name,
            @RequestParam("email") String email,
            @RequestParam("address") String address) {

        Customer customer = new Customer();
        customer.setId((long) (customers.size() + 1)); // Simplified ID generation
        customer.setName(name);
        customer.setEmail(email);
        customer.setAddress(address);

        customers.add(customer);
        return new ResponseEntity<>(customer, HttpStatus.CREATED);
    }

    // GET method to retrieve all customers
    @GetMapping
    public ResponseEntity<List<Customer>> getAllCustomers() {
        return new ResponseEntity<>(customers, HttpStatus.OK);
    }
}