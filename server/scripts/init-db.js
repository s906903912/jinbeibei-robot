#!/usr/bin/env node

/**
 * Cloudflare D1 数据库初始化脚本
 * 使用 REST API 执行 SQL 语句
 */

const https = require('https');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const { CF_ACCOUNT_ID, CF_DATABASE_ID, CF_API_TOKEN } = process.env;

if (!CF_ACCOUNT_ID || !CF_DATABASE_ID || !CF_API_TOKEN) {
  console.error('❌ 缺少必要的环境变量！');
  console.error('请确保 .env 文件包含：CF_ACCOUNT_ID, CF_DATABASE_ID, CF_API_TOKEN');
  process.exit(1);
}

// 读取 SQL schema
const schemaPath = path.join(__dirname, '../../sql/schema.sql');
const schema = fs.readFileSync(schemaPath, 'utf8');

// 分割 SQL 语句
const statements = schema
  .split(';')
  .map(s => s.trim())
  .filter(s => s.length > 0 && !s.startsWith('--'));

console.log(`📋 准备执行 ${statements.length} 条 SQL 语句...\n`);

// 执行 SQL
async function executeSql(sql) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({ sql });
    
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
            resolve(result);
          } else {
            reject(new Error(result.errors?.[0]?.message || '执行失败'));
          }
        } catch (e) {
          reject(e);
        }
      });
    });

    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

// 主函数
async function main() {
  let successCount = 0;
  let errorCount = 0;

  for (let i = 0; i < statements.length; i++) {
    const sql = statements[i];
    const preview = sql.substring(0, 60).replace(/\n/g, ' ');
    
    try {
      await executeSql(sql);
      console.log(`✅ [${i + 1}/${statements.length}] ${preview}...`);
      successCount++;
    } catch (error) {
      console.error(`❌ [${i + 1}/${statements.length}] ${preview}...`);
      console.error(`   错误: ${error.message}`);
      errorCount++;
    }
  }

  console.log('\n' + '='.repeat(50));
  console.log(`✅ 成功: ${successCount} 条`);
  console.log(`❌ 失败: ${errorCount} 条`);
  console.log('='.repeat(50));

  if (errorCount === 0) {
    console.log('\n🎉 数据库初始化完成！');
  } else {
    console.log('\n⚠️  部分语句执行失败，请检查错误信息');
    process.exit(1);
  }
}

main().catch(console.error);
