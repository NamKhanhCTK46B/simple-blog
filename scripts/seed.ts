import { createClient } from '@supabase/supabase-js';
import { faker } from '@faker-js/faker';
import * as dotenv from 'dotenv';
import path from 'path';

// Load environment variables from .env.local
dotenv.config({ path: path.resolve(process.cwd(), '.env.local') });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('Missing environment variables. Please check .env.local');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

function slugify(text: string) {
  return text
    .toString()
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')     // Replace spaces with -
    .replace(/[^\w-]+/g, '')  // Remove all non-word chars
    .replace(/--+/g, '-');    // Replace multiple - with single -
}

async function seed() {
  console.log('🚀 Starting seeding process...');

  try {
    // 1. Clean up existing data (optional but recommended for a fresh start)
    console.log('🧹 Cleaning up old data...');
    // Delete in reverse order of dependencies
    await supabase.from('comments').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    await supabase.from('posts').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    await supabase.from('categories').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    
    // Note: Deleting Auth Users is more complex as it requires looping through the list
    // We'll skip it for safety unless specifically requested, or just append new users.
    // For this script, we'll try to create new users and handle conflicts.

    // 2. Create Users (1 Admin, 5 Users)
    console.log('👥 Creating users...');
    const users = [];
    
    // Create Admin
    const adminEmail = 'admin@example.com';
    const adminPassword = 'Password123!';
    const { data: adminAuth, error: adminError } = await supabase.auth.admin.createUser({
      email: adminEmail,
      password: adminPassword,
      email_confirm: true,
      user_metadata: { full_name: 'System Admin', avatar_url: faker.image.avatar() }
    });

    if (adminError && adminError.message !== 'User already registered') {
        console.error('Error creating admin:', adminError.message);
    } else {
        const adminId = adminAuth?.user?.id || (await supabase.from('profiles').select('id').eq('display_name', 'System Admin').single()).data?.id;
        if (adminId) {
            await supabase.from('profiles').update({ role: 'admin', display_name: 'System Admin' }).eq('id', adminId);
            users.push({ id: adminId, role: 'admin' });
            console.log('✅ Admin created: admin@example.com / Password123!');
        }
    }

    // Create 5 Regular Users
    for (let i = 1; i <= 5; i++) {
      const email = `user${i}@example.com`;
      const fullName = faker.person.fullName();
      const { data: userAuth, error: userError } = await supabase.auth.admin.createUser({
        email: email,
        password: 'Password123!',
        email_confirm: true,
        user_metadata: { full_name: fullName, avatar_url: faker.image.avatar() }
      });

      if (userError && userError.message !== 'User already registered') {
        console.error(`Error creating user ${email}:`, userError.message);
      } else {
        const userId = userAuth?.user?.id || (await supabase.from('profiles').select('id').eq('display_name', fullName).single()).data?.id;
        if (userId) {
            await supabase.from('profiles').update({ role: 'user', display_name: fullName }).eq('id', userId);
            users.push({ id: userId, role: 'user' });
        }
      }
    }
    console.log(`✅ Created ${users.filter(u => u.role === 'user').length} regular users.`);

    const adminUser = users.find(u => u.role === 'admin');
    const regularUsers = users.filter(u => u.role === 'user');

    if (!adminUser) throw new Error('Admin user could not be found or created.');

    // 3. Create Categories
    console.log('📁 Creating categories...');
    const categoryNames = ['Technology', 'Software Development', 'Web Design', 'Lifestyle', 'Travel', 'Food'];
    const { data: categories, error: catError } = await supabase
      .from('categories')
      .insert(categoryNames.map(name => ({ name, slug: slugify(name) })))
      .select();

    if (catError) throw catError;
    console.log(`✅ Created ${categories.length} categories.`);

    // 4. Create Posts (assigned to Admin)
    console.log('📝 Creating posts...');
    const postsData = [];
    for (let i = 0; i < 20; i++) {
      const title = faker.lorem.sentence();
      const status = faker.helpers.arrayElement(['published', 'published', 'published', 'draft']); // More published than drafts
      postsData.push({
        author_id: adminUser.id,
        category_id: faker.helpers.arrayElement(categories).id,
        title: title,
        slug: `${slugify(title)}-${faker.string.alphanumeric(5)}`,
        excerpt: faker.lorem.paragraph().substring(0, 150) + '...',
        content: `## ${title}\n\n${faker.lorem.paragraphs(3)}\n\n### ${faker.lorem.words(3)}\n\n${faker.lorem.paragraphs(2)}`,
        status: status,
        published_at: status === 'published' ? new Date().toISOString() : null
      });
    }

    const { data: posts, error: postError } = await supabase.from('posts').insert(postsData).select();
    if (postError) throw postError;
    console.log(`✅ Created ${posts.length} posts.`);

    // 5. Create Comments (assigned to Regular Users on published posts)
    console.log('💬 Creating comments...');
    const publishedPosts = posts.filter(p => p.status === 'published');
    const commentsData = [];

    for (const post of publishedPosts) {
      const commentCount = faker.number.int({ min: 1, max: 4 });
      for (let j = 0; j < commentCount; j++) {
        commentsData.push({
          post_id: post.id,
          author_id: faker.helpers.arrayElement(regularUsers).id,
          content: faker.lorem.sentences(faker.number.int({ min: 1, max: 3 }))
        });
      }
    }

    const { error: commentError } = await supabase.from('comments').insert(commentsData);
    if (commentError) throw commentError;
    console.log(`✅ Created ${commentsData.length} comments.`);

    console.log('✨ Seeding completed successfully!');
  } catch (error: any) {
    console.error('❌ Seeding failed:', error.message);
  }
}

seed();
