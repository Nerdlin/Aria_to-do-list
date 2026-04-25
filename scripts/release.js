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

  // Спрашиваем данные для релиза
  const response = await prompts([
    {
      type: 'text',
      name: 'newVersion',
      message: 'Введи новую версию (например, 1.0.1):',
      initial: currentVersion
    },
    {
      type: 'text',
      name: 'downloadUrl',
      message: 'Ссылка на скачивание нового APK (Google Drive/Dropbox/т.д.):',
      validate: value => value.startsWith('http') ? true : 'Нужна корректная http/https ссылка'
    },
    {
      type: 'text',
      name: 'releaseNotes',
      message: 'Что нового в этой версии? (Опиши для пользователей):'
    },
    {
      type: 'confirm',
      name: 'isMandatory',
      message: 'Это критичное обновление? (пользователь не сможет закрыть окно)',
      initial: false
    }
  ]);

  if (!response.newVersion || !response.downloadUrl) {
    console.log('❌ Релиз отменен.');
    process.exit(0);
  }

  const newBuild = currentBuild + 1;

  // Обновляем pubspec.yaml
  console.log('\n📝 Обновляем pubspec.yaml...');
  pubspec = pubspec.replace(/version: \d+\.\d+\.\d+\+\d+/, `version: ${response.newVersion}+${newBuild}`);
  fs.writeFileSync(pubspecPath, pubspec);
  console.log(`✅ Версия обновлена на ${response.newVersion}+${newBuild}`);

  // Собираем APK
  console.log('\n📦 Собираем release APK (это займет пару минут)...');
  try {
    execSync('flutter build apk --release', { stdio: 'inherit', cwd: path.join(__dirname, '..') });
    console.log('✅ APK успешно собран!');
  } catch (e) {
    console.error('❌ Ошибка сборки APK:', e.message);
    process.exit(1);
  }

  // Обновляем Firestore
  console.log('\n🔥 Обновляем конфигурацию в Firebase Firestore...');
  try {
    await db.collection('config').doc('app_version').set({
      latestVersion: response.newVersion,
      downloadUrl: response.downloadUrl,
      releaseNotes: response.releaseNotes || 'Улучшения производительности и исправления ошибок.',
      isMandatory: response.isMandatory
    }, { merge: true });
    
    console.log('✅ Firestore обновлен!');
  } catch (e) {
    console.error('❌ Ошибка при обновлении Firestore:', e);
  }

  console.log('\n🎉 РЕЛИЗ ГОТОВ!');
  console.log(`Твой APK находится здесь: build/app/outputs/flutter-apk/app-release.apk`);
  console.log(`Обязательно загрузи его по ссылке: ${response.downloadUrl}`);
  process.exit(0);
}

run();
