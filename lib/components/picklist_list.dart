import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:picklist_ui/components/checkbox_controller.dart';
import 'package:picklist_ui/components/list_shimmer.dart';
import 'package:picklist_ui/components/picklist_item.dart';
import 'package:picklist_ui/http/http.dart';
import 'package:picklist_ui/models/picklist_model.dart';

class PicklistList extends StatefulWidget {
  const PicklistList({
    super.key,
  });

  @override
  State<PicklistList> createState() => _PicklistListState();
}

class _PicklistListState extends State<PicklistList> {
  late List<PickListModel> picklists;

  @override
  Widget build(BuildContext context) {
    Future<dynamic> futurePicklist = Http.getPicklist();
    createListOfPicklist(futurePicklist);

    return Align(
      alignment: Alignment.topCenter,
      child: Card(
        margin: EdgeInsets.only(bottom: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.only(left: 64.0, right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SizedBox(
                        width: 650,
                        child: Text(
                          'Cliente',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                        width: 126,
                        child: Text(
                          'Data de criação',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                        width: 109,
                        child: Text(
                          'Picklist ID',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
            ),
            FutureBuilder<dynamic>(
              future: futurePicklist,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (picklists.isEmpty) {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Não há picklists à liberar'),
                    ));
                  } else {
                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: picklists.length,
                        itemBuilder: ((context, int index) {
                          var item = picklists.elementAt(index);
                          return PickListItem(
                            item: item,
                          );
                        }),
                      ),
                    );
                  }
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Não foi possível carregar a lista'),
                  ));
                }
                return const ListShimmer();
              },
            ),
          ],
        ),
      ),
    );
  }

  void createListOfPicklist(Future<dynamic> futureList) {
    futureList.then((response) {
      List list = jsonDecode(response.body);
      picklists = list.map((model) => PickListModel.fromJson(model)).toList();
    });
  }
}
