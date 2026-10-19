class BranchOffice {
  final String region;
  final String city;
  final String address;
  final String phone;
  final String email;

  const BranchOffice({
    required this.region,
    required this.city,
    required this.address,
    required this.phone,
    required this.email,
  });
}

class CompanyData {
  CompanyData._();

  static const String companyName = 'Milen Trading';
  static const String legalName = 'Milen Trading';
  static const String companySubtitle = 'Structural Steel & Metal Trading';
  static const String website = 'www.milantrades.com';
  static const String websiteUrl = 'https://www.milantrades.com';

  static const List<BranchOffice> branches = [
    BranchOffice(
      region: 'WESTERN REGION',
      city: 'JEDDAH',
      address:
          'Souq-7, Ibn Ladin Street, Al Rawabi District, Jeddah, Saudi Arabia',
      phone: '+966 597 67 87 97',
      email: 'info@milantrades.com',
    ),
    BranchOffice(
      region: 'CENTRAL REGION',
      city: 'RIYADH',
      address:
          '2nd Industrial City, Al Misfat, Al Kharj Road, Riyadh, Saudi Arabia',
      phone: '+966 569 79 49 71',
      email: 'sales@milantrades.com',
    ),
    BranchOffice(
      region: 'EASTERN REGION',
      city: 'DAMMAM',
      address: '7727 – 3rd Industrial City, 2224-34856, Dammam, Saudi Arabia',
      phone: '+966 566 51 28 99',
      email: 'sales@milantrades.com',
    ),
  ];

  static const String primaryWhatsAppNumber = '966597678797';

  static String getWhatsAppInquiryUrl(String text) {
    return 'https://wa.me/$primaryWhatsAppNumber?text=${Uri.encodeComponent(text)}';
  }
}
