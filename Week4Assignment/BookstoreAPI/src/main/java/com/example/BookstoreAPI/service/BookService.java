package com.example.BookstoreAPI.service;

import com.example.BookstoreAPI.dto.BookDTO;
import com.example.BookstoreAPI.model.Book;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class BookService {

    @Autowired
    private ModelMapper modelMapper;

    // Method to convert a Book entity to a BookDTO
    public BookDTO convertToDTO(Book book) {
        return modelMapper.map(book, BookDTO.class);
    }

    // Method to convert a BookDTO to a Book entity
    public Book convertToEntity(BookDTO bookDTO) {
        return modelMapper.map(bookDTO, Book.class);
    }
}
