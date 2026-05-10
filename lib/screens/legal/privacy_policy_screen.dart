import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 18,
    );
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.6);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text('Polityka Prywatności'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Polityka Prywatności — Aura Catch',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Data obowiązywania: 7 maja 2026 r.',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Nazwa aplikacji: Aura Catch',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Wersja dokumentu: 1.0',
              style: bodyStyle,
            ),
            const SizedBox(height: 20),

            Text('1. Informacje ogólne', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'Niniejsza Polityka Prywatności określa zasady przetwarzania danych osobowych użytkowników aplikacji mobilnej oraz platformy webowej „Aura Catch” („Aplikacja”).',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Administratorem Danych Osobowych jest:\nDariusz Szweda\nul. Batalionów Chłopskich 15\n41-400 Mysłowice, Polska',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'W sprawach dotyczących ochrony danych osobowych można kontaktować się pod adresem e-mail: office@auracatch.com',
              style: bodyStyle,
            ),

            const SizedBox(height: 16),
            Text('2. Zakres przetwarzanych danych', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'Aura Catch przetwarza wyłącznie następujące dane użytkownika:',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text('- adres e-mail podany podczas rejestracji lub logowania do konta.', style: bodyStyle),
            const SizedBox(height: 8),
            Text(
              'Administrator nie przetwarza szczególnych kategorii danych osobowych ani danych wrażliwych.',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Aplikacja korzysta z aparatu i mikrofonu. Obraz i głos są przetwarzane chwilowo przez Gemini AI API w celu rozpoznawania produktów i natychmiast usuwane z pamięci (Zero Retention). Nie przechowujemy zdjęć ani nagrań głosowych na naszych serwerach.',
              style: bodyStyle,
            ),

            const SizedBox(height: 16),
            Text('3. Cele przetwarzania danych', style: headingStyle),
            const SizedBox(height: 8),
            Text('Dane osobowe są przetwarzane wyłącznie w celu:', style: bodyStyle),
            const SizedBox(height: 8),
            Text('- utworzenia i obsługi konta użytkownika,', style: bodyStyle),
            Text('- umożliwienia korzystania z funkcjonalności Aplikacji,', style: bodyStyle),
            Text('- komunikacji technicznej i związanej z bezpieczeństwem konta,', style: bodyStyle),
            Text('- realizacji obowiązków prawnych wynikających z przepisów prawa,', style: bodyStyle),
            Text('- ochrony przed nadużyciami oraz zapewnienia bezpieczeństwa usług.', style: bodyStyle),

            const SizedBox(height: 16),
            Text('4. Podstawa prawna przetwarzania danych', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'Dane osobowe przetwarzane są zgodnie z Rozporządzeniem Parlamentu Europejskiego i Rady (UE) 2016/679 („RODO”) na podstawie:',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text('- art. 6 ust. 1 lit. b RODO — wykonanie umowy lub świadczenie usług drogą elektroniczną,', style: bodyStyle),
            Text(
              '- art. 6 ust. 1 lit. f RODO — prawnie uzasadniony interes Administratora, polegający na zapewnieniu bezpieczeństwa i prawidłowego działania Aplikacji,',
              style: bodyStyle,
            ),
            Text('- art. 6 ust. 1 lit. c RODO — wypełnienie obowiązków prawnych.', style: bodyStyle),

            const SizedBox(height: 16),
            Text('5. Udostępnianie danych', style: headingStyle),
            const SizedBox(height: 8),
            Text('Administrator nie sprzedaje danych osobowych użytkowników.', style: bodyStyle),
            const SizedBox(height: 8),
            Text(
              'Dane mogą być przekazywane wyłącznie podmiotom wspierającym funkcjonowanie Aplikacji, takim jak:',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text('- dostawcy hostingu,', style: bodyStyle),
            Text('- dostawcy usług technicznych i infrastrukturalnych,', style: bodyStyle),
            Text('- dostawcy usług poczty elektronicznej,', style: bodyStyle),
            Text('- podmioty świadczące usługi bezpieczeństwa IT.', style: bodyStyle),
            const SizedBox(height: 8),
            Text(
              'Dane mogą być przekazywane poza Europejski Obszar Gospodarczy wyłącznie zgodnie z mechanizmami przewidzianymi przez RODO.',
              style: bodyStyle,
            ),

            const SizedBox(height: 16),
            Text('6. Linki afiliacyjne i programy partnerskie', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'Aura Catch korzysta z linków afiliacyjnych i programów partnerskich, w tym między innymi:',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text('- Amazon Associates,', style: bodyStyle),
            Text('- AWIN,', style: bodyStyle),
            Text('- Allegro Partner Program.', style: bodyStyle),
            const SizedBox(height: 8),
            Text(
              'Oznacza to, że Administrator może otrzymywać prowizję od kwalifikujących się zakupów dokonanych po przejściu przez linki dostępne w Aplikacji.',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text('Jako partner afiliacyjny zarabiamy na kwalifikujących się zakupach.', style: bodyStyle),
            const SizedBox(height: 8),
            Text(
              'Kliknięcie linków afiliacyjnych może powodować przekierowanie do zewnętrznych serwisów internetowych, które posiadają własne polityki prywatności oraz zasady przetwarzania danych.',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text('Administrator nie odpowiada za praktyki prywatności stosowane przez podmioty trzecie.', style: bodyStyle),

            const SizedBox(height: 16),
            Text('7. Informacje o cenach i wyłączenie odpowiedzialności', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'Aura Catch monitoruje ceny produktów na wielu rynkach i w sklepach internetowych. Pomimo dokładania należytej staranności:',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text('- ceny prezentowane w Aplikacji mogą być opóźnione,', style: bodyStyle),
            Text('- ceny mogą różnić się od aktualnych cen obowiązujących w sklepach,', style: bodyStyle),
            Text('- dostępność produktów może ulec zmianie,', style: bodyStyle),
            Text('- informacje mogą zawierać błędy techniczne lub synchronizacyjne.', style: bodyStyle),
            const SizedBox(height: 8),
            Text(
              'Administrator nie gwarantuje poprawności, kompletności ani aktualności prezentowanych cen i nie ponosi odpowiedzialności za decyzje zakupowe podjęte na podstawie danych prezentowanych w Aplikacji.',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Wiążąca cena produktu jest zawsze ceną widoczną bezpośrednio w sklepie lub serwisie sprzedawcy w momencie zakupu.',
              style: bodyStyle,
            ),

            const SizedBox(height: 16),
            Text('8. Retencja danych', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              '8.1. Dla użytkowników planu FREE: Dane dotyczące śledzonych produktów są usuwane z bazy po 30 dniach od zakończenia okresu śledzenia.',
              style: bodyStyle,
            ),
            const SizedBox(height: 6),
            Text(
              '8.2. Dane konta są przechowywane do momentu skorzystania przez użytkownika z funkcji „Usuń konto i dane".',
              style: bodyStyle,
            ),

            const SizedBox(height: 16),
            Text('9. Prawa użytkownika', style: headingStyle),
            const SizedBox(height: 8),
            Text('Użytkownik ma prawo do:', style: bodyStyle),
            const SizedBox(height: 8),
            Text('- dostępu do swoich danych,', style: bodyStyle),
            Text('- sprostowania danych,', style: bodyStyle),
            Text('- usunięcia danych,', style: bodyStyle),
            Text('- ograniczenia przetwarzania,', style: bodyStyle),
            Text('- przenoszenia danych,', style: bodyStyle),
            Text('- wniesienia sprzeciwu wobec przetwarzania,', style: bodyStyle),
            Text('- wniesienia skargi do właściwego organu nadzorczego.', style: bodyStyle),
            const SizedBox(height: 8),
            Text(
              'W Polsce organem nadzorczym jest Prezes Urzędu Ochrony Danych Osobowych (PUODO).',
              style: bodyStyle,
            ),

            const SizedBox(height: 16),
            Text('10. Bezpieczeństwo danych', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'Administrator stosuje odpowiednie środki techniczne i organizacyjne mające na celu ochronę danych osobowych przed utratą, nieuprawnionym dostępem lub ujawnieniem.',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Super admin, administrator, ani żaden pomocnik administratora strony nie ma i nigdy nie będzie miał dostępu do prywatnych danych finansowych użytkowników.',
              style: bodyStyle,
            ),

            const SizedBox(height: 16),
            Text('11. Zmiany Polityki Prywatności', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'Administrator zastrzega sobie prawo do aktualizacji niniejszej Polityki Prywatności. Aktualna wersja będzie publikowana w Aplikacji oraz na stronie internetowej.',
              style: bodyStyle,
            ),
          ],
        ),
      ),
    );
  }
}
