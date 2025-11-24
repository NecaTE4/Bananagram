import 'dart:io';
import 'package:bananagram/screen/post_text_screen.dart';
import 'package:bananagram/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_manager/photo_manager.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final List<Widget> _mediaList = [];
  final List<File> path = [];
  File? _file;
  int currentPage = 0;
  int? lastPage;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchNewMedia());
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _fetchNewMedia() async {
    lastPage = currentPage;
    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    if (!ps.isAuth) return;

    final album = await PhotoManager.getAssetPathList(type: RequestType.image);
    final media = await album[0].getAssetListPaged(page: currentPage, size: 60);

    for (var asset in media) {
      if (asset.type == AssetType.image) {
        final file = await asset.file;
        if (file != null) {
          path.add(File(file.path));
          _file ??= path[0];
        }
      }
    }

    List<Widget> temp = [];
    for (var asset in media) {
      temp.add(
        FutureBuilder(
          future: asset.thumbnailDataWithSize(ThumbnailSize(1000, 1000)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              );
            }
            return const Center(child: LoadingWidget());
          },
        ),
      );
    }

    if (!mounted || _isDisposed) return;

    setState(() {
      _mediaList.addAll(temp);
      currentPage++;
    });
  }

  int indexx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'new post',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Billabong',
              fontSize: 36.r,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: GestureDetector(
                onTap: _file == null
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostTextScreen(_file!),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: _file == null ? Colors.grey : Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _mediaList.isEmpty
            ? const Center(
          child: LoadingWidget(),
        )
            : SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 375.h,
                child: GridView.builder(
                  itemCount:
                  _mediaList.isEmpty ? 0 : 1,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 1,
                  ),
                  itemBuilder: (context, index) {
                    return _mediaList[indexx];
                  },
                ),
              ),
              Container(
                width: double.infinity,
                height: 40.h,
                color: Colors.white,
                child: Row(
                  children: [
                    SizedBox(width: 10.w),
                    Text(
                      'Recent',
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _mediaList.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (!mounted) return;
                      setState(() {
                        indexx = index;
                        _file = path[index];
                      });
                    },
                    child: _mediaList[index],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
