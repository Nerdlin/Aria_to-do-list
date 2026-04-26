const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const admin = require('firebase-admin');
const prompts = require('prompts');

// 1. Убедимся, что ключ скачан
const keyPath = path.join(__dirname, 'serviceAccountKey.json');
if (!fs.existsSync(keyPath)) {
  console.error('\n❌ Ошибка: Не найден сервисный ключ Firebase (serviceAccountKey.json)!');
  console.error('Чтобы этот скрипт работал, тебе нужно:');
  console.error('1. Зайти в Firebase Console -> Project Settings -> Service Accounts');
  console.error('2. Нажать "Generate new private key"');
  console.error('3. Скачать JSON файл, переименовать его в "serviceAccountKey.json"');
  console.error('4. Положить его в папку "scripts" (рядом с этим скриптом)');
  process.exit(1);
}

// Инициализация Firebase
const serviceAccount = require(keyPath);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
const db = admin.firestore();

async function run() {
  console.log('🚀 Начинаем процесс релиза Aria...\n');

  // Читаем текущую версию из pubspec.yaml
  const pubspecPath = path.join(__dirname, '../pubspec.yaml');
  let pubspec = fs.readFileSync(pubspecPath, 'utf8');
  const versionMatch = pubspec.match(/version: (\d+\.\d+\.\d+)\+(\d+)/);
  
  if (!versionMatch) {
    console.error('❌ Не удалось найти версию в pubspec.yaml');
    process.exit(1);
  }

  const currentVersion = versionMatch[1];
  const currentBuild = parseInt(versionMatch[2], 10);
  
  console.log(`Текущая версия: ${currentVersion}+${currentBuild}`);

  // 1. Сначала спрашиваем базовые данные
  const initialInfo = await prompts([
    {
      type: 'text',
      name: 'newVersion',
      message: 'Введи новую версию (например, 1.0.1):',
      initial: currentVersion
    },
    {
      type: 'text',
      name: 'releaseNotes',
      message: 'Что нового в этой версии? (Опиши для пользователей):',
      initial: 'Улучшения производительности и исправления ошибок.'
    },
    {
      type: 'confirm',
      name: 'isMandatory',
      message: 'Это критичное обновление? (пользователь не сможет закрыть окно)',
      initial: false
    }
  ]);

  if (!initialInfo.newVersion) {
    console.log('❌ Релиз отменен.');
    process.exit(0);
  }

  const newBuild = currentBuild + 1;

  // 2. Обновляем pubspec.yaml
  console.log('\n📝 Обновляем pubspec.yaml...');
  pubspec = pubspec.replace(/version: \d+\.\d+\.\d+\+\d+/, `version: ${initialInfo.newVersion}+${newBuild}`);
  fs.writeFileSync(pubspecPath, pubspec);
  console.log(`✅ Версия обновлена на ${initialInfo.newVersion}+${newBuild}`);

  // 3. Собираем APK
  console.log('\n📦 Собираем release APK (это займет пару минут)...');
  try {
    execSync('flutter build apk --release', { stdio: 'inherit', cwd: path.join(__dirname, '..') });
    console.log('\n✅ APK успешно собран!');
    console.log(`📍 Файл находится здесь: build/app/outputs/flutter-apk/app-release.apk`);
  } catch (e) {
    console.error('❌ Ошибка сборки APK:', e.message);
    process.exit(1);
  }

  // 4. ТЕПЕРЬ просим загрузить и дать ссылку
  console.log('\n⬇️  ДЕЙСТВИЕ ТРЕБУЕТСЯ:');
  console.log('1. Загрузите созданный APK файл в ваше облако (Google Диск и т.д.)');
  console.log('2. Скопируйте прямую ссылку на файл.');
  
  const linkInfo = await prompts([
    {
      type: 'text',
      name: 'downloadUrl',
      message: 'Вставьте ссылку на скачивание APK:',
      validate: value => value.startsWith('http') ? true : 'Нужна корректная http/https ссылка'
    }
  ]);

  if (!linkInfo.downloadUrl) {
    console.log('❌ Обновление базы отменено (но APK собран).');
    process.exit(0);
  }

  // 5. Обновляем Firestore
  console.log('\n🔥 Обновляем конфигурацию в Firebase Firestore...');
  try {
    await db.collection('config').doc('app_version').set({
      latestVersion: initialInfo.newVersion,
      latestBuildNumber: newBuild,
      downloadUrl: linkInfo.downloadUrl,
      releaseNotes: initialInfo.releaseNotes,
      isMandatory: initialInfo.isMandatory,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });
    
    console.log('✅ Firestore обновлен!');
  } catch (e) {
    console.error('❌ Ошибка при обновлении Firestore:', e);
  }

  console.log('\n🎉 РЕЛИЗ ПОЛНОСТЬЮ ГОТОВ!');
  console.log(`Версия: ${initialInfo.newVersion}+${newBuild}`);
  console.log(`Ссылка в базе: ${linkInfo.downloadUrl}`);
  process.exit(0);
}

run();
