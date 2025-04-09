import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'symptom_catalog.dart';

class SymptomscatalogScreen extends StatefulWidget {
  const SymptomscatalogScreen({super.key});

  @override
  SymptomscatalogScreenState createState() => SymptomscatalogScreenState();
}

class SymptomscatalogScreenState extends State<SymptomscatalogScreen> {
  final TextEditingController _searchsymptoms = TextEditingController();
  List<String> _filteredSymptom = [];
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    final allSymptoms =
        (symptomCatalog['CatalogSymptom'] as Map<String, dynamic>)
            .keys
            .toList();
    _filteredSymptom = List.from(allSymptoms);

    Future.delayed(Duration.zero, () async {
      await _loadHeavySymptomMap();
      setState(() => _isReady = true);
    });
  }

  Future<void> _loadHeavySymptomMap() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _filterSearchResults(String query) {
    final allSymptoms =
        (symptomCatalog['CatalogSymptom'] as Map<String, dynamic>)
            .keys
            .toList();
    
    // Remove all whitespace from both the query and symptoms
    final cleanQuery = query.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        _filteredSymptom = List.from(allSymptoms);
      });
    } else {
      setState(() {
        _filteredSymptom = allSymptoms
            .where((item) => 
                item.replaceAll(RegExp(r'\s+'), '').toLowerCase().contains(cleanQuery))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1D1D2C),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Center(
            child: Text(
              "Symptoms Catalog",
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Oswald',
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        body: !_isReady
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitPulse(
                      color: const Color(0xFF52AAA4),
                      size: 80.w,
                    ),
                    SizedBox(height: 25.h),
                    Text(
                      "Loading Symptoms...",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Oswald',
                        color: const Color(0xFF1D1D2C),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                    child: TextField(
                      controller: _searchsymptoms,
                      onChanged: _filterSearchResults,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Search Symptoms',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 16.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: const Color(0xFF52AAA4),
                          size: 26.w,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide: BorderSide(
                            color: const Color(0xFF52AAA4),
                            width: 2.w,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: ListView.builder(
                        itemCount: _filteredSymptom.length,
                        itemBuilder: (context, index) {
                          final symptomName = _filteredSymptom[index];
                          final symptomData = symptomCatalog['CatalogSymptom'][symptomName];
                          final symptomList = symptomData['Description'] as List<dynamic>;
                          final symptomDescription = symptomList.isNotEmpty
                              ? symptomList[0]
                              : 'No description available.';
                          final symptomImg = symptomData['Image'] as List<dynamic>?;
                          final symptomImage = (symptomImg != null && symptomImg.isNotEmpty)
                              ? symptomImg.first
                              : 'assets/catanddog.jpg';

                          return Card(
                            elevation: 0,
                            color: const Color(0xFF1D1D2C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: 
                            Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent,
                             highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              splashFactory: NoSplash.splashFactory,),
                            child:
                            ExpansionTile(
                              title: Text(
                                symptomName,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFE8F2F5),
                                ),
                              ),
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 300.w,
                                        height: 300.h,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20.r),
                                          child: Image.asset(
                                            symptomImage,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                                      child: Text(
                                        symptomDescription,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: const Color.fromRGBO(66, 134, 130, 1.0),
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
                                  ],
                                ),
                              ],
                            )),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}