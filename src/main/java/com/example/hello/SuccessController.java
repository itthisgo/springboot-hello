package com.example.hello;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SuccessController {
	
	@GetMapping("/success")
	public String success() {
		return "deploy success!!";
	}

}
