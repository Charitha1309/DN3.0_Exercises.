package com.example.BookstoreAPI.controller;

import com.example.BookstoreAPI.model.Book;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.BookstoreAPI.exception.BookNotFoundException;


import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/books")
public class BookController {

    private List<Book> books = new ArrayList<>();

    // GET method to retrieve all books
    @GetMapping
    @ResponseStatus(HttpStatus.OK) // Using @ResponseStatus for 200 OK
    public List<Book> getAllBooks() {
        return books;
    }

    // POST method to add a new book
    @PostMapping
    public ResponseEntity<Book> createBook(@RequestBody Book book) {
        books.add(book);

        // Adding custom headers
        HttpHeaders headers = new HttpHeaders();
        headers.add("X-Custom-Header", "Book-Creation");

        return ResponseEntity.status(HttpStatus.CREATED)
                .headers(headers)
                .body(book);
    }

    // PUT method to update a book by ID
    @PutMapping("/{id}")
    public ResponseEntity<Book> updateBook(@PathVariable Long id, @RequestBody Book updatedBook) {
        for (Book book : books) {
            if (book.getId().equals(id)) {
                book.setTitle(updatedBook.getTitle());
                book.setAuthor(updatedBook.getAuthor());
                book.setPrice(updatedBook.getPrice());
                book.setIsbn(updatedBook.getIsbn());

                // Adding custom headers
                HttpHeaders headers = new HttpHeaders();
                headers.add("X-Custom-Header", "Book-Update");

                return ResponseEntity.ok().headers(headers).body(book);
            }
        }
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    // DELETE method to remove a book by ID
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT) // Using @ResponseStatus for 204 No Content
    public void deleteBook(@PathVariable Long id) {
        books.removeIf(book -> book.getId().equals(id));
    }

    // GET method to retrieve a book by ID using path variable
    @GetMapping("/{id}")
    public ResponseEntity<Book> getBookById(@PathVariable Long id) {
        for (Book book : books) {
            if (book.getId().equals(id)) {
                HttpHeaders headers = new HttpHeaders();
                headers.add("X-Custom-Header", "Book-Found");
                return ResponseEntity.ok().headers(headers).body(book);
            }
        }
        throw new BookNotFoundException("Book with ID " + id + " not found.");
    }


    // GET method to filter books by query parameters (title and/or author)
    @GetMapping("/search")
    public ResponseEntity<List<Book>> searchBooks(
            @RequestParam(required = false) String title,
            @RequestParam(required = false) String author) {

        List<Book> filteredBooks = new ArrayList<>(books);

        if (title != null && !title.isEmpty()) {
            filteredBooks.removeIf(book -> !book.getTitle().equalsIgnoreCase(title));
        }

        if (author != null && !author.isEmpty()) {
            filteredBooks.removeIf(book -> !book.getAuthor().equalsIgnoreCase(author));
        }

        // Adding custom headers
        HttpHeaders headers = new HttpHeaders();
        headers.add("X-Custom-Header", "Book-Search");

        return ResponseEntity.ok().headers(headers).body(filteredBooks);
    }
}
