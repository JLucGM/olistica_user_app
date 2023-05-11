import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../category/controllers/categories_controller.dart';
import '../../category/widgets/category_list_item_widget.dart';
import '../../global_widgets/circular_loading_widget.dart';
import '../../../../common/ui.dart';
import '../../../models/slide_model.dart';
import '../../../providers/laravel_provider.dart';
import '../../../services/settings_service.dart';
import '../../global_widgets/address_widget.dart';
import '../../global_widgets/home_search_bar_widget.dart';
import '../../global_widgets/notifications_button_widget.dart';
import '../controllers/home_controller.dart';
import '../widgets/slide_item_widget.dart';

class Home2View extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    var _currentUser = Get.find<AuthService>().user;

    final controllerCategories = Get.put(CategoriesController());

    return Scaffold(
      body: RefreshIndicator(
          onRefresh: () async {
            Get.find<LaravelApiClient>().forceRefresh();
            await controller.refreshHome(showMessage: true);
            Get.find<LaravelApiClient>().unForceRefresh();
          },
          child: CustomScrollView(
            primary: true,
            shrinkWrap: false,
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                expandedHeight: 300,
                elevation: 0.5,
                floating: true,
                iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                title: Text(
                  Get.find<SettingsService>().setting.value.appName,
                  style: Get.textTheme.titleLarge,
                ),
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: new IconButton(
                  icon: new Icon(Icons.sort, color: Colors.black87),
                  onPressed: () => {Scaffold.of(context).openDrawer()},
                ),
                actions: [NotificationsButtonWidget()],
                bottom: HomeSearchBarWidget(),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Obx(() {
                    return Stack(
                      alignment: controller.slider.isEmpty
                          ? AlignmentDirectional.center
                          : Ui.getAlignmentDirectional(controller.slider
                              .elementAt(controller.currentSlide.value)
                              .textPosition),
                      children: <Widget>[
                        CarouselSlider(
                          options: CarouselOptions(
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 7),
                            height: 360,
                            viewportFraction: 1.0,
                            onPageChanged: (index, reason) {
                              controller.currentSlide.value = index;
                            },
                          ),
                          items: controller.slider.map((Slide slide) {
                            return SlideItemWidget(slide: slide);
                          }).toList(),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 70, horizontal: 20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: controller.slider.map((Slide slide) {
                              return Container(
                                width: 20.0,
                                height: 5.0,
                                margin: EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    color: controller.currentSlide.value ==
                                            controller.slider.indexOf(slide)
                                        ? slide.indicatorColor
                                        : slide.indicatorColor
                                            .withOpacity(0.4)),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  }),
                ).marginOnly(bottom: 42),
              ),
              SliverToBoxAdapter(
                child: Wrap(
                  children: [
                    AddressWidget(),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Hola '.tr,
                                      style: Get.textTheme.displayLarge),
                                  Text(_currentUser.value.name ?? '',
                                      style: Get.textTheme.displayLarge),
                                ],
                              ),
                              Text("What service would you like today?".tr,
                                  style: Get.textTheme.displayMedium),
                            ],
                          )),
                        ],
                      ),
                    ),
//                    CategoriesCarouselWidget(),
                    Obx(() {
                      return Offstage(
                        offstage: controllerCategories.layout.value !=
                            CategoriesLayout.LIST,
                        child: controllerCategories.categories.isEmpty
                            ? CircularLoadingWidget(height: 400)
                            : ListView.separated(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                primary: false,
                                itemCount:
                                    controllerCategories.categories.length,
                                separatorBuilder: (context, index) {
                                  return SizedBox(height: 10);
                                },
                                itemBuilder: (context, index) {
                                  return CategoryListItemWidget(
                                    heroTag: 'category_list',
                                    expanded: index == 0,
                                    category: controllerCategories.categories
                                        .elementAt(index),
                                  );
                                },
                              ),
                      );
                    }),
                    // RecommendedCarouselWidget(),
                    // FeaturedCategoriesWidget(),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
