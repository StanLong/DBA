package com.stanlong.clickhouse.controller;

import com.stanlong.clickhouse.service.IotDataService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/iot")
@RequiredArgsConstructor
public class IotDataController {
    final IotDataService iotDataService;
    @GetMapping("/list")
    public Object list(){
        return iotDataService.list();
    }
}