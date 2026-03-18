#!/usr/bin/env node

/**
 * Cloudflare D1 连接测试脚本
 * 逐个测试配置参数是否正确
 */

const https = require('https');
require('dotenv').config();

const { CF_ACCOUNT_ID, CF_DATABASE_ID, CF_API_TOKEN } = process.env;

console.log('🔍 开始诊断 Cloudflare D1 连接...\n');

// 1. 检查环境变量
console.log('📋 步骤 1: 检查环境变量');
console.log('─'.repeat(50));

if (!CF_ACCOUNT_ID) {
  console.log('❌ CF_ACCOUNT_ID 未设置');
} else {
  console.log(`✅ CF_ACCOUNT_ID: ${CF_ACCOUNT_ID.substring(0, 8)}...`);
}

if (!CF_DATABASE_ID) {
  console.log('❌ CF_DATABASE_ID 未设置');
} else {
  console.log(`✅ CF_DATABASE_ID: ${CF_DATABASE_ID.substring(0, 8)}...`);
}

if (!CF_API_TOKEN) {
  console.log('❌ CF_API_TOKEN 未设置');
} else {
  console.log(`✅ CF_API_TOKEN: ${CF_API_TOKEN.substring(0, 8)}...`);
}

if (!CF_ACCOUNT_ID || !CF_DATABASE_ID || !CF_API_TOKEN) {
  console.log('\n❌ 缺少必要的环境变量！');
  process.exit(1);
}

console.log('\n');

// 2. 测试 Account ID
console.log('📋 步骤 2: 测试 Account ID');
console.log('─'.repeat(50));

testAccountId().then(() => {
  console.log('\n');
  
  // 3. 测试 API Token
  console.log('📋 步骤 3: 测试 API Token 权限');
  console.log('─'.repeat(50));
  
  return testApiToken();
}).then(() => {
  console.log('\n');
  
  // 4. 测试 Database ID
  console.log('📋 步骤 4: 测试 Database ID');
  console.log('─'.repeat(50));
  
  return testDatabaseId();
}).then(() => {
  console.log('\n');
  console.log('🎉 所有测试通过！数据库连接正常！');
}).catch(error => {
  console.log('\n');
  console.log('❌ 诊断完成，发现问题：');
  console.log(error.message);
  process.exit(1);
});

// 测试 Account ID
function testAccountId() {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.cloudflare.com',
      port: 443,
      path: `/client/v4/accounts/${CF_ACCOUNT_ID}`,
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${CF_API_TOKEN}`,
        'Content-Type': 'application/json',
      },
    };

    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const result = JSON.parse(body);
          if (result.success) {
            console.log(`✅ Account ID 正确`);
            console.log(`   账户名称: ${result.result.name}`);
            resolve();
          } else {
            const error = result.errors?.[0];
            console.log(`❌ Account ID 错误`);
            console.log(`   错误代码: ${error?.code}`);
            console.log(`   错误信息: ${error?.message}`);
            reject(new Error('Account ID 不正确或无权限访问'));
          }
        } catch (e) {
          reject(new Error('解析响应失败: ' + e.message));
        }
      });
    });

    req.on('error', (e) => reject(new Error('网络请求失败: ' + e.message)));
    req.end();
  });
}

// 测试 API Token
function testApiToken() {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.cloudflare.com',
      port: 443,
      path: '/client/v4/user/tokens/verify',
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${CF_API_TOKEN}`,
        'Content-Type': 'application/json',
      },
    };

    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const result = JSON.parse(body);
          if (result.success) {
            console.log(`✅ API Token 有效`);
            console.log(`   状态: ${result.result.status}`);
            resolve();
          } else {
            console.log(`❌ API Token 无效`);
            reject(new Error('API Token 不正确或已过期'));
          }
        } catch (e) {
          reject(new Error('解析响应失败: ' + e.message));
        }
      });
    });

    req.on('error', (e) => reject(new Error('网络请求失败: ' + e.message)));
    req.end();
  });
}

// 测试 Database ID
function testDatabaseId() {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({ sql: 'SELECT 1 as test' });
    
    const options = {
      hostname: 'api.cloudflare.com',
      port: 443,
      path: `/client/v4/accounts/${CF_ACCOUNT_ID}/d1/database/${CF_DATABASE_ID}/query`,
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${CF_API_TOKEN}`,
        'Content-Type': 'application/json',
        'Content-Length': data.length,
      },
    };

    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const result = JSON.parse(body);
          if (result.success) {
            console.log(`✅ Database ID 正确`);
            console.log(`   测试查询成功`);
            resolve();
          } else {
            const error = result.errors?.[0];
            console.log(`❌ Database ID 错误`);
            console.log(`   错误代码: ${error?.code}`);
            console.log(`   错误信息: ${error?.message}`);
            reject(new Error('Database ID 不正确或数据库不存在'));
          }
        } catch (e) {
          reject(new Error('解析响应失败: ' + e.message));
        }
      });
    });

    req.on('error', (e) => reject(new Error('网络请求失败: ' + e.message)));
    req.write(data);
    req.end();
  });
}
