import 'package:flutter/material.dart';

class PackageCard extends StatelessWidget {
  // Lab information
  final String? labLogo;
  final String? labName;
  final double? rating;
  final bool showLabName;
  
  // Package information
  final String packageName;
  final String? description;
  final double originalPrice;
  final double offerPrice;
  final String? gender;
  final bool fastingRequired;
  final String? fastingDuration;
  final String? reportTime;
  final List<Map<String, dynamic>>? testsIncluded;
  final bool isPopular;
  
  // Interaction
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const PackageCard({
    super.key,
    // Lab info
    this.labLogo,
    this.labName,
    this.rating,
    this.showLabName = true,
    // Package info
    required this.packageName,
    this.description,
    required this.originalPrice,
    required this.offerPrice,
    this.gender,
    this.fastingRequired = false,
    this.fastingDuration,
    this.reportTime,
    this.testsIncluded,
    this.isPopular = false,
    // Interactions
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate discount percentage
    final discountPercent = originalPrice > 0 
        ? (((originalPrice - offerPrice) / originalPrice) * 100).round()
        : 0;
    
    // Format tests included for display
    String getTestsPreview() {
      if (testsIncluded == null || testsIncluded!.isEmpty) return '';
      
      List<String> allTests = [];
      
      try {
        for (var category in testsIncluded!) {
          final tests = category['tests'];
          if (tests is List) {
            for (var test in tests) {
              if (test != null) {
                allTests.add(test.toString());
              }
            }
          }
        }
        
        if (allTests.isEmpty) return '';
        
        if (allTests.length <= 3) {
          return allTests.join(', ');
        } else {
          return '${allTests.take(3).join(', ')} +${allTests.length - 3} more';
        }
      } catch (e) {
        print('PackageCard: Error formatting tests preview: $e');
        return 'Tests included';
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lab info (if showLabName is true)
                  if (showLabName && labName != null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            labLogo ?? 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/240px-No_image_available.svg.png'
                          ),
                          radius: 16,
                          backgroundColor: Colors.grey.shade200,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            labName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (rating != null) ...[
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Package name and popular badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          packageName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'POPULAR',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Description (if available)
                  if (description != null && description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // Price section
                  Row(
                    children: [
                      if (originalPrice > offerPrice) ...[
                        Text(
                          "₹${originalPrice.toStringAsFixed(0)}",
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        "₹${offerPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (discountPercent > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "$discountPercent% OFF",
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // // Tests preview section
            // if (testsIncluded != null && testsIncluded!.isNotEmpty) ...[
            //   Container(
            //     width: double.infinity,
            //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //     decoration: BoxDecoration(
            //       color: Colors.grey.shade50,
            //       border: Border(
            //         top: BorderSide(color: Colors.grey.shade200),
            //         bottom: BorderSide(color: Colors.grey.shade200),
            //       ),
            //     ),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Tests Included:',
            //           style: TextStyle(
            //             fontSize: 12,
            //             fontWeight: FontWeight.w600,
            //             color: Colors.grey.shade700,
            //           ),
            //         ),
            //         const SizedBox(height: 4),
            //         Text(
            //           getTestsPreview(),
            //           style: TextStyle(
            //             fontSize: 12,
            //             color: Colors.grey.shade600,
            //             height: 1.3,
            //           ),
            //           maxLines: 2,
            //           overflow: TextOverflow.ellipsis,
            //         ),
            //       ],
            //     ),
            //   ),
            // ],
            
            // Bottom info and action section
            // Padding(
            //   padding: const EdgeInsets.all(16),
            //   child: Column(
            //     children: [
            //       // Info tags row
            //       Row(
            //         children: [
            //           // Gender info
            //           if (gender != null && gender != 'Male / Female') ...[
            //             Container(
            //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //               decoration: BoxDecoration(
            //                 color: Colors.blue.shade50,
            //                 borderRadius: BorderRadius.circular(8),
            //               ),
            //               child: Text(
            //                 gender!,
            //                 style: TextStyle(
            //                   fontSize: 10,
            //                   color: Colors.blue.shade700,
            //                   fontWeight: FontWeight.w500,
            //                 ),
            //               ),
            //             ),
            //             const SizedBox(width: 8),
            //           ],
                      
            //           // Report time
            //           if (reportTime != null && reportTime!.isNotEmpty) ...[
            //             Row(
            //               children: [
            //                 Icon(Icons.timer, size: 12, color: Colors.green.shade600),
            //                 const SizedBox(width: 4),
            //                 Text(
            //                   reportTime!,
            //                   style: TextStyle(
            //                     fontSize: 11,
            //                     color: Colors.green.shade600,
            //                     fontWeight: FontWeight.w500,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //             const Spacer(),
            //           ],
                      
            //           // Fasting required
            //           if (fastingRequired) ...[
            //             Container(
            //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //               decoration: BoxDecoration(
            //                 color: Colors.orange.shade50,
            //                 borderRadius: BorderRadius.circular(8),
            //               ),
            //               child: Row(
            //                 mainAxisSize: MainAxisSize.min,
            //                 children: [
            //                   Icon(Icons.no_food, size: 12, color: Colors.orange.shade700),
            //                   const SizedBox(width: 4),
            //                   Text(
            //                     fastingDuration ?? 'Fasting Required',
            //                     style: TextStyle(
            //                       fontSize: 10,
            //                       color: Colors.orange.shade700,
            //                       fontWeight: FontWeight.w500,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ],
            //       ),
                  
            //       const SizedBox(height: 12),
                  
            //       // Action button
            //       if (onAddToCart != null) ...[
            //         SizedBox(
            //           width: double.infinity,
            //           child: ElevatedButton(
            //             onPressed: onAddToCart,
            //             style: ElevatedButton.styleFrom(
            //               backgroundColor: Colors.teal,
            //               foregroundColor: Colors.white,
            //               padding: const EdgeInsets.symmetric(vertical: 12),
            //               shape: RoundedRectangleBorder(
            //                 borderRadius: BorderRadius.circular(8),
            //               ),
            //               elevation: 0,
            //             ),
            //             child: const Text(
            //               'Add to Cart',
            //               style: TextStyle(
            //                 fontWeight: FontWeight.w600,
            //                 fontSize: 14,
            //               ),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
