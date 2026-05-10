import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
        title: const Text('Regulamin'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Regulamin — Aura Catch',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Data obowiązywania: 7 maja 2026 r.',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Wersja dokumentu: 1.0',
              style: bodyStyle,
            ),
            const SizedBox(height: 20),

            Text('1. Postanowienia ogólne', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'Właścicielem serwisu oraz aplikacji Aura Catch jest Dariusz Szweda.',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Niniejszy Regulamin określa zasady korzystania z aplikacji mobilnej oraz platformy webowej „Aura Catch”.',
              style: bodyStyle,
            ),
            Text(
              'Korzystanie z Aplikacji oznacza akceptację niniejszego Regulaminu.',
              style: bodyStyle,
            ),

            const SizedBox(height: 16),
            Text('2. Funkcjonalność Aplikacji', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'Aura Catch umożliwia użytkownikom monitorowanie cen produktów na 31 rynkach oraz dostęp do informacji o ofertach i promocjach.',
              style: bodyStyle,
            ),
            Text('Aplikacja ma charakter informacyjny i pomocniczy.', style: bodyStyle),
            const SizedBox(height: 8),
            Text(
              'Administrator nie jest sprzedawcą produktów prezentowanych w Aplikacji i nie uczestniczy w zawieraniu umów sprzedaży pomiędzy użytkownikiem a sklepem lub platformą sprzedażową.',
              style: bodyStyle,
            ),

            const SizedBox(height: 16),
            Text('3. Zasady Subskrypcji i Limity (Plan FREE)', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              '3.1. Użytkownik planu FREE może śledzić produkt przez okres 30 dni od momentu jego dodania.',
              style: bodyStyle,
            ),
            const SizedBox(height: 6),
            Text(
              '3.2. W planie FREE aktualizacja ceny odbywa się 1 raz na dobę (co 24 godziny), w okolicach godziny, w której produkt został dodany do bazy.',
              style: bodyStyle,
            ),
            const SizedBox(height: 6),
            Text(
              '3.3. Po upływie 30 dni śledzenie zostaje zakończone, a dane historyczne produktu są archiwizowane zgodnie z Polityką Prywatności.',
              style: bodyStyle,
            ),

            const SizedBox(height: 16),
            Text('4. Konto użytkownika', style: headingStyle),
            const SizedBox(height: 8),
            Text('Założenie konta wymaga podania adresu e-mail.', style: bodyStyle),
            Text(
              'Użytkownik zobowiązuje się do podawania prawdziwych danych oraz do nieudostępniania konta osobom trzecim.',
              style: bodyStyle,
            ),
            Text(
              'Administrator może usunąć konto użytkownika w przypadku naruszenia Regulaminu lub przepisów prawa.',
              style: bodyStyle,
            ),

            const SizedBox(height: 16),
            Text('5. Linki afiliacyjne i wynagrodzenie', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'Aura Catch korzysta z programów partnerskich i linków afiliacyjnych, w tym Amazon Associates, AWIN oraz Allegro Partner Program.',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Administrator może otrzymywać wynagrodzenie lub prowizję za kwalifikujące się zakupy dokonane po przejściu przez link afiliacyjny dostępny w Aplikacji.',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text('Kliknięcie linków może powodować przekierowanie do zewnętrznych serwisów internetowych.', style: bodyStyle),

            const SizedBox(height: 16),
            Text('6. Wyłączenie odpowiedzialności', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'Administrator dokłada należytej staranności w zakresie poprawności danych prezentowanych w Aplikacji, jednak:',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text('- nie gwarantuje aktualności cen,', style: bodyStyle),
            Text('- nie gwarantuje dostępności produktów,', style: bodyStyle),
            Text('- nie gwarantuje poprawności opisów i informacji pochodzących od podmiotów trzecich.', style: bodyStyle),
            const SizedBox(height: 8),
            Text(
              'Ceny prezentowane w Aura Catch mogą różnić się od cen obowiązujących bezpośrednio w sklepach internetowych lub marketplace’ach.',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text('Administrator nie ponosi odpowiedzialności za:', style: bodyStyle),
            const SizedBox(height: 8),
            Text('- błędy cenowe,', style: bodyStyle),
            Text('- opóźnienia aktualizacji danych,', style: bodyStyle),
            Text('- niedostępność produktów,', style: bodyStyle),
            Text('- decyzje zakupowe użytkowników,', style: bodyStyle),
            Text('- działania lub oferty podmiotów trzecich.', style: bodyStyle),
            const SizedBox(height: 8),
            Text(
              'Wiążące są wyłącznie informacje prezentowane bezpośrednio przez sprzedawcę w momencie zakupu.',
              style: bodyStyle,
            ),

            const SizedBox(height: 16),
            Text('7. Odpowiedzialność użytkownika', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'Użytkownik zobowiązuje się do korzystania z Aplikacji zgodnie z obowiązującym prawem oraz dobrymi obyczajami.',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text('Zakazane jest:', style: bodyStyle),
            const SizedBox(height: 8),
            Text('- podejmowanie działań mogących zakłócić działanie Aplikacji,', style: bodyStyle),
            Text('- próby nieautoryzowanego dostępu do systemów Administratora,', style: bodyStyle),
            Text('- wykorzystywanie Aplikacji w sposób sprzeczny z prawem.', style: bodyStyle),

            const SizedBox(height: 16),
            Text('8. Własność intelektualna', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'Wszelkie prawa do Aplikacji, jej kodu źródłowego, znaków graficznych, treści i funkcjonalności przysługują Administratorowi lub odpowiednim licencjodawcom.',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Kopiowanie, rozpowszechnianie lub wykorzystywanie elementów Aplikacji bez zgody Administratora jest zabronione.',
              style: bodyStyle,
            ),

            const SizedBox(height: 16),
            Text('9. Dostępność usług', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'Administrator może czasowo ograniczyć dostęp do Aplikacji w związku z pracami technicznymi, konserwacją lub aktualizacją systemu.',
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text('Administrator nie gwarantuje nieprzerwanego i bezbłędnego działania Aplikacji.', style: bodyStyle),

            const SizedBox(height: 16),
            Text('10. Rozwiązanie umowy', style: headingStyle),
            const SizedBox(height: 8),
            Text('Użytkownik może w dowolnym momencie usunąć konto i zaprzestać korzystania z Aplikacji.', style: bodyStyle),
            const SizedBox(height: 8),
            Text(
              'Administrator zastrzega sobie prawo do zawieszenia lub usunięcia konta użytkownika w przypadku naruszenia Regulaminu lub obowiązujących przepisów prawa.',
              style: bodyStyle,
            ),

            const SizedBox(height: 16),
            Text('11. Zmiany Regulaminu', style: headingStyle),
            const SizedBox(height: 8),
            Text('Administrator może zmieniać niniejszy Regulamin w przypadku:', style: bodyStyle),
            const SizedBox(height: 8),
            Text('- zmian prawnych,', style: bodyStyle),
            Text('- zmian technologicznych,', style: bodyStyle),
            Text('- rozszerzenia funkcjonalności Aplikacji,', style: bodyStyle),
            Text('- zmian organizacyjnych.', style: bodyStyle),
            const SizedBox(height: 8),
            Text('Nowa wersja Regulaminu będzie publikowana w Aplikacji oraz na stronie internetowej.', style: bodyStyle),

            const SizedBox(height: 16),
            Text('12. Prawo właściwe', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'Do korzystania z Aplikacji zastosowanie ma prawo polskie oraz odpowiednie przepisy prawa Unii Europejskiej, w tym RODO.',
              style: bodyStyle,
            ),

            const SizedBox(height: 16),
            Text('13. Kontakt', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'Kontakt z Administratorem:\noffice@auracatch.com\n\nDariusz Szweda\nul. Batalionów Chłopskich 15\n41-400 Mysłowice, Polska',
              style: bodyStyle,
            ),
          ],
        ),
      ),
    );
  }
}
