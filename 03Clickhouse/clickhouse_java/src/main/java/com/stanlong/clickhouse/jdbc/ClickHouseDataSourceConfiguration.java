package com.stanlong.clickhouse.jdbc;

import com.alibaba.druid.pool.DruidDataSource;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

@Configuration
public class ClickHouseDataSourceConfiguration {

    @Bean
    @ConfigurationProperties(prefix = "spring.datasource.clickhouse")
    public DataSource clickDruidDataSource(){
        return new DruidDataSource();
    }
}
