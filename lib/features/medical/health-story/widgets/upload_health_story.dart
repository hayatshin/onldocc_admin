import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view_a/modal_screen.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/medical/health-story/models/health_story_model.dart';
import 'package:onldocc_admin/features/medical/health-story/repo/health_story_repo.dart';
import 'package:onldocc_admin/features/medical/health-story/view_models/health_story_view_model.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:uuid/uuid.dart';

class UploadHealthStory extends ConsumerStatefulWidget {
  final Function() updateHealthStoreis;
  final HealthStoryModel? model;
  const UploadHealthStory({
    super.key,
    required this.updateHealthStoreis,
    this.model,
  });

  @override
  ConsumerState<UploadHealthStory> createState() => _UploadHealthStoryState();
}

class _UploadHealthStoryState extends ConsumerState<UploadHealthStory> {
  final TextEditingController _titleControllder = TextEditingController();
  final QuillController _quillController = QuillController.basic(
    config: QuillControllerConfig(
      clipboardConfig: QuillClipboardConfig(
        enableExternalRichPaste: true,
      ),
    ),
  );
  String? _healthStoryId;
  HealthStoryModel? _model;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  @override
  void dispose() {
    _titleControllder.dispose();
    _quillController.dispose();
    super.dispose();
  }

  void _initializeModel() {
    if (widget.model == null) {
      _healthStoryId = Uuid().v4();
      return;
    }

    _healthStoryId = widget.model!.healthStoryId;
    _titleControllder.text = widget.model!.title;

    final List<dynamic> deltaDesc = jsonDecode(widget.model!.description);
    final doc = Document.fromJson(deltaDesc);
    _quillController.document = doc;
  }

  Future<void> _submitContent() async {
    final title = _titleControllder.text;
    final descDelta = _quillController.document.toDelta();
    final descIsEmpty = descDelta.length == 1 && descDelta.first.data == '\n';
    final jsonDelta = descDelta.toJson();

    final adminProfile = ref.read(adminProfileProvider).value;
    if (adminProfile == null) return;
    if (adminProfile.doctor == null || adminProfile.doctor?.role != "guide") {
      showTopWarningSnackBar(context, "작성 권한을 가진 의사가 아닙니다");
      return;
    }

    if (title.isEmpty) {
      showTopWarningSnackBar(context, "콘텐츠의 제목을 작성해주세요");
      return;
    }

    if (descIsEmpty) {
      showTopWarningSnackBar(context, "콘텐츠의 내용을 작성해주세요");
      return;
    }
    final healthStoryId = _healthStoryId ?? Uuid().v4();

    List<Map<String, dynamic>> updatedDesc = [];
    for (var op in jsonDelta) {
      if (op.containsKey('insert') &&
          op['insert'] is Map &&
          op['insert']['image'] != null) {
        final imageUrl = op['insert']['image'];
        if (imageUrl.toString().startsWith('blob:')) {
          final newUrl = await ref
              .read(healthStoryRepo)
              .uploadSingleBlobToHealthStoryStorage(healthStoryId, imageUrl);
          op['insert']['image'] = newUrl;
        }
      } else if (op.containsKey('insert') &&
          op['insert'] is Map &&
          op['insert']['video'] != null) {
        final imageUrl = op['insert']['video'];
        if (imageUrl.toString().startsWith('blob:')) {
          final newUrl = await ref
              .read(healthStoryRepo)
              .uploadSingleBlobToHealthStoryStorage(healthStoryId, imageUrl);
          op['insert']['video'] = newUrl;
        }
      }
      updatedDesc.add(op);
    }

    final contentModel = HealthStoryModel(
      healthStoryId: healthStoryId,
      doctorId: adminProfile.doctor!.doctorId,
      title: title,
      description: jsonEncode(updatedDesc),
      createdAt: getCurrentSeconds(),
    );
    await ref
        .read(healthStoryProvider.notifier)
        .insertHealthStory(contentModel);
    if (!mounted) return;
    widget.updateHealthStoreis();
    context.pop();
    final snackBarText =
        widget.model == null ? "콘텐츠가 성공적으로 등록되었어요" : "콘텐츠가 성공적으로 수정되었어요";
    showTopCompletingSnackBar(context, snackBarText);
  }

  @override
  Widget build(BuildContext context) {
    return ModalScreen(
      widthPercentage: 0.5,
      modalTitle: "콘텐츠 등록하기",
      modalButtonOneText: "등록하기",
      modalButtonOneFunction: _submitContent,
      scroll: false,
      addBtn: false,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleControllder,
                      style: InjicareFont().headline04.copyWith(
                            color: InjicareColor().gray100,
                          ),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "제목",
                          hintStyle: InjicareFont().headline04.copyWith(
                                color: InjicareColor().gray40,
                              )),
                    ),
                    Gaps.v10,
                    Container(
                      height: 1,
                      color: InjicareColor().gray30,
                    ),
                    Gaps.v10,
                    QuillSimpleToolbar(
                      controller: _quillController,
                      config: QuillSimpleToolbarConfig(
                        buttonOptions: QuillSimpleToolbarButtonOptions(
                          base: QuillToolbarBaseButtonOptions(
                            iconTheme: QuillIconTheme(),
                          ),
                        ),
                        embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                        showFontFamily: false,
                        showFontSize: false,
                        showItalicButton: false,
                        showSmallButton: false,
                        showUnderLineButton: false,
                        showLineHeightButton: false,
                        showStrikeThrough: false,
                        showInlineCode: false,
                        showClearFormat: false,
                        showAlignmentButtons: false,
                        showLeftAlignment: false,
                        showCenterAlignment: false,
                        showRightAlignment: false,
                        showJustifyAlignment: false,
                        showHeaderStyle: false,
                        showListNumbers: false,
                        showListBullets: false,
                        showListCheck: false,
                        showCodeBlock: false,
                        showQuote: true,
                        showIndent: false,
                        showLink: true,
                        showUndo: true,
                        showRedo: true,
                        showDirection: false,
                        showSearchButton: false,
                        showSubscript: false,
                        showSuperscript: false,
                        showClipboardCut: false,
                        showClipboardCopy: false,
                        showClipboardPaste: false,
                      ),
                    ),
                    Gaps.v10,
                    Expanded(
                      child: QuillEditor.basic(
                        controller: _quillController,
                        config: QuillEditorConfig(
                          placeholder: '콘텐츠 내용을 작성해주세요',
                          embedBuilders: [
                            ...FlutterQuillEmbeds.editorWebBuilders(),
                          ],
                          customStyles: DefaultStyles(
                            placeHolder: DefaultTextBlockStyle(
                                InjicareFont().body04.copyWith(
                                      color: InjicareColor().gray40,
                                    ),
                                HorizontalSpacing(0, 0),
                                VerticalSpacing(0, 0),
                                VerticalSpacing(0, 0),
                                null),
                            paragraph: DefaultTextBlockStyle(
                                InjicareFont().body04.copyWith(
                                      color: InjicareColor().gray100,
                                    ),
                                HorizontalSpacing(0, 0),
                                VerticalSpacing(0, 0),
                                VerticalSpacing(0, 0),
                                null),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
