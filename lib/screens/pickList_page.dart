import 'package:flutter/material.dart';
import 'package:picklist_ui/components/checkbox_controller.dart';
import 'package:picklist_ui/components/dialogs/error_dialog.dart';
import 'package:picklist_ui/components/dialogs/multistatus_dialog.dart';
import 'package:picklist_ui/components/nasajon_loader.dart';
import 'package:picklist_ui/components/dialogs/success_dialog.dart';
import 'package:picklist_ui/components/picklist_list.dart';

import 'package:picklist_ui/http/http.dart';
import 'package:picklist_ui/repositories/selected_picklists_repository.dart';

class PickListPage extends StatefulWidget {
  const PickListPage({Key? key}) : super(key: key);

  @override
  State<PickListPage> createState() => _PickListPageState();
}

class _PickListPageState extends State<PickListPage> {
  bool loading = false;
  bool buttomIsDisable = true;
  final controller = CheckboxController();

  @override
  Widget build(BuildContext context) {
    controller.addListener(() {
      setState(() {
        SelectedPickListRepository.selectedPickLists.isEmpty
            ? buttomIsDisable = false
            : buttomIsDisable = true;
      });
    });
    return loading
        ? const NsjLoader()
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(
                'Liberação de picklist',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.white,
            ),
            body: Padding(
              padding: const EdgeInsets.only(
                top: 32,
                left: 32,
                right: 32,
              ),
              child: Center(
                child: SizedBox(
                  width: 800,
                  child: PicklistList(
                    controller: controller,
                  ),
                ),
              ),
            ),
            bottomSheet: Padding(
              padding: const EdgeInsets.only(bottom: 64.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 94,
                    height: 40,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) {
                              return const Color.fromARGB(255, 234, 234, 234);
                            }
                            return const Color.fromARGB(255, 0, 69, 155);
                          },
                        ),
                      ),
                      onPressed: buttomIsDisable
                          ? null
                          : () async {
                              setState(() => loading = true);
                              var response = await Http.postPicklist(
                                  SelectedPickListRepository.selectedPickLists);

                              setState(() => loading = false);
                              showDialogSwitch(response);
                              SelectedPickListRepository.clear();
                            },
                      child: const Text('Liberar'),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  showDialogSwitch(response) {
    switch (response.globalStatus) {
      case "ERROR":
        showDialog(
          context: context,
          builder: (BuildContext context) => ErrorDialog(
            codigoErro: response.responseList.first.status.toString(),
            descricaoErro:
                response.responseList.first.body.message.substring(0, 52),
          ),
        );
        return;
      case "OK":
        showDialog(
          context: context,
          builder: (BuildContext context) => const SuccessDialog(),
        );
        return;
      case "MULTI-STATUS":
        showDialog(
          context: context,
          builder: (BuildContext context) => MultistatusDialog(
            list: response,
          ),
        );
        return;
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
