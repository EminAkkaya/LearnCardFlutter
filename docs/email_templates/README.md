# Supabase e-posta şablonları

Supabase → **Authentication → Emails → Templates**. Her şablonda konu satırını ve dosyanın
tamamını (HTML) ilgili kutuya yapıştırıp **Save**. Tasarım: Minimalist Tasarım Sistemi v1.1
(krem zemin, beyaz kart, adaçayı buton; gradient ve görsel yok, tablo düzeni e-posta
istemcileri için).

| Şablon | Konu | Dosya |
|---|---|---|
| Confirm signup | LearnCard doğrulama kodun: {{ .Token }} | confirm_signup.html |
| Reset password | LearnCard şifreni sıfırla | reset_password.html |
| Change email address | LearnCard e-posta değişikliğini onayla | change_email.html |

Bağlantıların uygulamaya dönmesi için **Authentication → URL Configuration**:
- **Redirect URLs**'e `io.learncard.app://login-callback` ekli olmalı. Ekli değilse Supabase
  `redirectTo` adresini yok sayıp **Site URL**'e (varsayılan `http://localhost:3000`) yönlendirir.
- **Site URL**: `io.learncard.app://login-callback` (web sitesi yayınlanınca
  `https://learncard.eminakkaya.dev` yapılabilir).
