import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'symptom_catalog.dart';

class SymptomscatalogScreen extends StatefulWidget {
  const SymptomscatalogScreen({super.key});

  @override
  SymptomscatalogScreenState createState() => SymptomscatalogScreenState();
}

class SymptomscatalogScreenState extends State<SymptomscatalogScreen> {

  final TextEditingController _searchsymptoms = TextEditingController();
  
  List<String> _filteredSymptom = [];

  @override
void initState() {
  super.initState();
  final allSymptoms = (symptomCatalog['CatalogSymptom'] as Map<String, dynamic>).keys.toList();
  _filteredSymptom = List.from(allSymptoms);
}

  void _filterSearchResults(String query) {
  final allSymptoms = (symptomCatalog['CatalogSymptom'] as Map<String, dynamic>).keys.toList();
  if (query.isEmpty) {
    setState(() {
      _filteredSymptom = List.from(allSymptoms);
    });
  } else {
    setState(() {
      _filteredSymptom = allSymptoms
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}

  


  @override
  Widget build(BuildContext context) {
    
    return PopScope(
      canPop: true, 
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 219, 230, 233),
         appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 29, 44, 1.0),
        elevation: 0,
        automaticallyImplyLeading: false,
        title:  Padding(padding: EdgeInsets.only(left:85.5.w),child:   Text(
                "Symptoms Catalog",
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Oswald',
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              )),
      ), // Lighter background for better contrast
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 25.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                TextField(
                          controller: _searchsymptoms,
                          onChanged: _filterSearchResults,
                          decoration: InputDecoration(
                            hintText: 'Search Symptoms',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.r),
                              borderSide: BorderSide(color: Colors.grey, width: 1.w),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.r),
                              borderSide: BorderSide(color: const Color.fromARGB(255, 172, 113, 220), width: 2.w),
                            ),
                          ),
                        ),
                SizedBox(height: 25.h),
                
                ListView.builder(
                      itemCount: _filteredSymptom.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final symptomName = _filteredSymptom[index];
                        final symptomList = symptomCatalog['CatalogSymptom'][symptomName]['Description'] as List<dynamic>;
                        final symptomDescription = symptomList.isNotEmpty ? symptomList[0] : 'No description available.';
                        final symptomImg = symptomCatalog['CatalogSymptom'][symptomName]['Image'] as List<dynamic>?; // use nullable cast
                        final symptomImage = (symptomImg != null && symptomImg.isNotEmpty)
                              ? symptomImg.first
                              : 'assets/catanddog.jpg'; // Default image if not found    

                        return 
                        ExpansionTile(
                          title: Text(symptomName),
                          children: <Widget>[
                            Column(
                              children: [
                                
                                SizedBox(height: 20.h),
                                Center(
                                  child: Container(
                                    width: 300.w,
                                    height:300.h,
                                    
                                    child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20.r), // Match with container radius
                                    child: Image.asset(
                                      symptomImage,
                                      fit: BoxFit.cover,
                                      width: 200.w,
                                      height: 200.h,
                                    ),
                                  ),
                                  ),
                                ),

                                // 👇 Add this for vertical spacing
                                SizedBox(height: 20.h),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        symptomDescription,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                  SizedBox(height: 20.h),
                              ],
                            ),
                          ],
                        );

                          },
                        ),

                
                
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

}