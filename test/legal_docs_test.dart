import 'package:cangur_app/l10n/legal_docs.dart';
import 'package:cangur_app/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legal documents follow the selected language and keep the company details', () {
    expect(legalDocument(LegalSection.terms).title, "Termes i condicions d'ús");
    expect(legalDocument(LegalSection.terms, AppLang.es).title, 'Términos y condiciones de uso');
    expect(legalDocument(LegalSection.terms, AppLang.en).title, 'Terms and conditions of use');
    expect(legalDocument(LegalSection.terms, AppLang.fr).title, "Conditions générales d'utilisation");

    expect(legalDocument(LegalSection.privacy, AppLang.es).updated, 'Última actualización: 08/03/2026');
    expect(legalDocument(LegalSection.privacy, AppLang.en).updated, 'Last updated: 08/03/2026');
    expect(legalDocument(LegalSection.privacy, AppLang.fr).updated, 'Dernière mise à jour : 08/03/2026');

    for (final lang in AppLang.values) {
      for (final section in LegalSection.values) {
        final doc = legalDocument(section, lang);
        final text = [
          doc.title,
          doc.updated,
          doc.footer ?? '',
          for (final block in doc.blocks) block.text,
          for (final block in doc.blocks) ...block.items,
          for (final block in doc.blocks) ...block.rows.map((row) => '${row.$1} ${row.$2}'),
        ].join('\n');
        expect(text, contains('infomoncangur@gmail.com'));
        expect(text, contains('+376 620 991'));
      }
      for (final section in [LegalSection.terms, LegalSection.privacy]) {
        final doc = legalDocument(section, lang);
        final facts = [for (final block in doc.blocks) ...block.rows.map((row) => row.$2)].join('\n');
        expect(facts, contains('F-370532-N'));
        expect(facts, contains('Lima Terra, Júlia'));
      }
      final terms = legalDocument(LegalSection.terms, lang).blocks.map((block) => block.text).join('\n');
      expect(terms.toLowerCase(), contains('catal'));
    }
  });
}
