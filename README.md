# Mouse Enter

Windows için AutoHotkey v2 mouse kısayolları.

## Davranış

- **Sol tık:** beklemeden çalışır; sürükleme hemen başlar.
- **Sol + sağ tuş:** bir tuş basılıyken diğerine basınca yaklaşık **50 ms sonra Enter** gönderilir. İki basış arasında süre sınırı yoktur.
- **Sağ tık:** en fazla 120 ms bekletilir; kısa basış bırakıldığında gönderilir.
- **Orta tuş:** kısa basış normal orta tık; 300 ms basılı tutma Windows ekran alıntısını açar (Win+Shift+S).
- **Kapatma:** Ctrl+Alt+F12 veya sistem tepsisi menüsü.

Sol tuş önce basılırsa ilk sol tık uygulamaya ulaşır. Birleşik basış algılandığında gönderilmiş mouse basışı serbest bırakılır ve Enter zamanlanır. Tuşları erken bırakmak planlanan Enter'ı iptal etmez. Windows zamanlayıcısı nedeniyle 50 ms yaklaşık bir değerdir.

## Kurulum ve çalıştırma

1. Bu repoyu indirin veya klonlayın.
2. [AutoHotkey v2.0.27](https://github.com/AutoHotkey/AutoHotkey/releases/tag/v2.0.27) paketini resmi kaynaktan indirin.
3. Projede bir runtime klasörü oluşturup AutoHotkey64.exe dosyasını içine koyun.
4. PowerShell'de proje klasöründen çalıştırın:

    powershell -ExecutionPolicy Bypass -File .\Start.ps1

Durdurmak için Ctrl+Alt+F12 kullanın veya:

    powershell -ExecutionPolicy Bypass -File .\Stop.ps1

Başlangıca otomatik ekleme yapılmaz. AutoHotkey çalışma zamanı, yerel loglar ve eski sürüm yedekleri repoya dahil değildir.

## Nasıl çalışıyor?

MouseEnter.ahk sol ve sağ tuşun durumunu ayrı izler. Sol basış hemen iletilir. Diğer tuş basılıyken ikinci basış algılanırsa bekleyen sağ tık iptal edilir; daha önce iletilmiş basış serbest bırakılır ve tek seferlik SetTimer ile Enter gönderilir. Aynı basışı tekrar işleme almamak için tuş durumları tutulur.

Enter gecikmesi: SetTimer(SendChordEnter, -50).
Sağ tık bekleme süresi: Schedule(button, -120).
Orta tuş ekran alıntısı eşiği: SetTimer(MiddleHold, -300).

## Kontroller

Betikte 15 dahili kontrol bulunur; sol tık, iki basış sırası, tekrar engelleme, orta tuş ve gerçek Enter zamanlayıcısını kapsar.

    .\runtime\AutoHotkey64.exe /ErrorStdOut .\MouseEnter.ahk --test

Başarılı sonuç: PASS: 15 checks including real timer.
Test modu aynı betiğin çalışan örneğini kapatabilir; testten sonra Start.ps1 ile tekrar başlatın.
