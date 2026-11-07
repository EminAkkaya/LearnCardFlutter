# LearnCard — Toplanan Veriler (Play Data Safety / Apple App Privacy)

Koddan çıkarılmıştır (2026-11-07). Yeni bir servis eklenince güncelle.

## Toplanan veriler
| Veri | Neden | Nerede | Kullanıcıya bağlı mı |
| --- | --- | --- | --- |
| E-posta adresi | Hesap oluşturma, giriş, doğrulama | Supabase Auth | Evet |
| Kullanıcı ID | Verileri hesaba bağlamak | Supabase | Evet |
| Kelime kartları, tekrar geçmişi (SRS) | Uygulama işlevi, cihazlar arası senkron | Supabase + cihaz | Evet |
| Kaydedilen okuma metinleri | Uygulama işlevi, senkron | Supabase + cihaz | Evet |
| Uygulama içi istatistikler (seri, oyun skoru) | Uygulama işlevi | Yalnız cihaz | Hayır |

- Misafir modunda hiçbir veri sunucuya gönderilmez; her şey cihazda kalır.
- Reklam, analitik, konum, kişiler, kamera, mikrofon **yok**.
- Veri satılmaz, üçüncü taraflarla reklam amacıyla paylaşılmaz.
- Aktarım HTTPS ile şifrelenir.
- Kullanıcı hesabını ve verilerini silebilir (uygulama içi hesap silme, görev S3).

## Üçüncü taraf servislere giden veriler
Türkçe karşılıklar uygulamaya gömülü sözlükten (Wiktionary, CC BY-SA 4.0) gelir. Kullanıcının
dokunduğu **kelime** şu servislere gönderilir (kişisel kimlik bilgisi gönderilmez); çeviri
servislerine yalnız kelime sözlükte yoksa ya da kullanıcı "çevrimiçi çeviri" isterse:
- `api.dictionaryapi.dev` — İngilizce tanım ve telaffuz sesi
- `api.mymemory.translated.net` — çeviri
- `translate.googleapis.com` — çeviri (**resmî olmayan uç nokta, bkz. plan SEC2**)

## Play Data Safety cevapları (özet)
- Data collected: Personal info → Email address (App functionality, Account management; required for account, optional overall since guest mode exists).
- App activity → Other user-generated content (flashcards, saved texts) (App functionality).
- Data shared: No. Encrypted in transit: Yes. Deletion request: Yes.

## Apple App Privacy (özet)
- Contact Info → Email Address: Linked to user, App Functionality.
- User Content → Other User Content: Linked to user, App Functionality.
- Identifiers → User ID: Linked to user, App Functionality.
- Tracking: No.
