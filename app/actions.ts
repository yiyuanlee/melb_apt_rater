'use server'

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';
import { headers } from 'next/headers';

export async function submitReview(formData: FormData) {
  const apartmentId = formData.get('apartmentId') as string;
  const score = parseInt(formData.get('score') as string);
  const content = formData.get('content') as string;

  // 1. 获取用户 IP (防止同一个人疯狂刷分)
  // 注意：在 Next.js 最新版中 headers() 是异步的，建议加上 await
  const headersList = await headers();
  const ip = headersList.get('x-forwarded-for') || 'unknown';
  
  // 简单的 IP Hash 处理 (实际生产可以用 bcrypt，这里简化处理)
  const ipHash = btoa(ip).slice(0, 10); 

  // 2. 检查该 IP 是否在 24 小时内给该公寓打过分
  const { data: existing } = await supabase
    .from('reviews')
    .select('id')
    .eq('apartment_id', apartmentId)
    .eq('ip_hash', ipHash)
    .gte('created_at', new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString())
    .single();

  if (existing) {
    return { error: '⚠️ 提交太频繁了，24小时内只能评一次哦' };
  }

  // 3. 写入数据库
  const { error } = await supabase.from('reviews').insert({
    apartment_id: apartmentId,
    score: score,
    content: content,
    ip_hash: ipHash,
  });

  if (error) {
    console.error('Supabase Error:', error);
    return { error: '提交失败，请重试' };
  }

  // 4. 关键修复：清除缓存，强制刷新数据
  
  // 刷新详情页：让用户看到自己的评论
  revalidatePath(`/apartment/${apartmentId}`);

  // 刷新首页：让首页的"平均分"和"评分人数"实时更新
  revalidatePath('/');

  return { success: true };
}