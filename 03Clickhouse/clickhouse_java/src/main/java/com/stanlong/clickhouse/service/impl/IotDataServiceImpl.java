package com.stanlong.clickhouse.service.impl;

import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.stanlong.clickhouse.dao.IotDataMapper;
import com.stanlong.clickhouse.entity.IotData;
import com.stanlong.clickhouse.service.IotDataService;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.Collections;
import java.util.Map;
import java.util.function.Function;

@Service
public class IotDataServiceImpl extends ServiceImpl<IotDataMapper, IotData> implements IotDataService {
    @Override
    public boolean saveBatch(Collection<IotData> entityList, int batchSize) {
        return false;
    }

    @Override
    public boolean saveOrUpdateBatch(Collection<IotData> entityList, int batchSize) {
        return false;
    }

    @Override
    public boolean updateBatchById(Collection<IotData> entityList, int batchSize) {
        return false;
    }

    @Override
    public boolean saveOrUpdate(IotData entity) {
        return false;
    }

    @Override
    public IotData getOne(Wrapper<IotData> queryWrapper, boolean throwEx) {
        return null;
    }

    @Override
    public Map<String, Object> getMap(Wrapper<IotData> queryWrapper) {
        return Collections.emptyMap();
    }

    @Override
    public <V> V getObj(Wrapper<IotData> queryWrapper, Function<? super Object, V> mapper) {
        return null;
    }

    @Override
    public IotDataMapper getBaseMapper() {
        return null;
    }
}