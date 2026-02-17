import 'package:html/dom.dart' as dom;

/// Styles for main article body content.
Map<String, String>? articleContentStylesBuilder(dom.Element element) {
  final tag = element.localName;
  switch (tag) {
    case 'p':
      return <String, String>{
        'font-size': '16px',
        'line-height': '1.8',
        'margin': '0 0 16px 0',
      };
    case 'h1':
      return <String, String>{
        'font-size': '28px',
        'font-weight': 'bold',
        'margin': '24px 0 12px 0',
      };
    case 'h2':
      return <String, String>{
        'font-size': '24px',
        'font-weight': 'bold',
        'margin': '20px 0 10px 0',
      };
    case 'h3':
      return <String, String>{
        'font-size': '20px',
        'font-weight': 'bold',
        'margin': '16px 0 8px 0',
      };
    case 'h4':
      return <String, String>{
        'font-size': '18px',
        'font-weight': 'bold',
        'margin': '12px 0 8px 0',
      };
    case 'blockquote':
      return <String, String>{
        'margin': '8px 0 8px 16px',
        'padding': '0 0 0 12px',
        'font-style': 'italic',
      };
    case 'a':
      return <String, String>{
        'text-decoration': 'underline',
      };
    case 'img':
      return <String, String>{
        'margin': '8px 0',
      };
    case 'figcaption':
      return <String, String>{
        'font-size': '13px',
        'margin': '4px 0 16px 0',
      };
    case 'figure':
      return <String, String>{
        'margin': '16px 0',
      };
  }
  return null;
}

/// Styles for brief / lead section.
Map<String, String>? briefStylesBuilder(dom.Element element) {
  final tag = element.localName;
  switch (tag) {
    case 'p':
      return <String, String>{
        'font-size': '15px',
        'line-height': '1.7',
        'margin': '0 0 8px 0',
      };
    case 'a':
      return <String, String>{
        'text-decoration': 'underline',
      };
  }
  return null;
}
