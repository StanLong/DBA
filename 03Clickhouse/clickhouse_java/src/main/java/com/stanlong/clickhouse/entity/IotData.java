package com.stanlong.clickhouse.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

@TableName("Iot_data")
@Data
public class IotData {
    Long id;
    Integer cpuTmp;
    Short cpuUseRatio;
    // 时间相关属性必须使用@JsonFormat
    @JsonFormat(locale="zh", timezone="GMT+8", pattern="yyyy-MM-dd HH:mm:ss")
    LocalDateTime timestamp;
}
