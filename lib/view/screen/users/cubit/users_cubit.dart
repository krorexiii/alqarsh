import 'package:alkhafajdashboard/data/repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../data/model/locationModel.dart';
import '../../../../data/model/userModel.dart';
import '../../../../utils/constVar.dart';

part 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit() : super(UsersInitial());
  final Repository _repository = Repository();
  String? userId;
  List<UserModel> users = [];
  List<LocationModel> locations = [];

  saveUser({
    required String username,
    required String password,
    required String name,
    required String role,
    required String locationId,
  }) async {
    emit(UsersLoading());
    try {
      if (locations.isEmpty) {
        emit(UsersError('لا توجد مواقع متجر متاحة لربط المستخدم بها'));
        return;
      }

      UserModel user = UserModel(
        username: username.trim(),
        password: password,
        name: name,
        role: ConstVar.roleList.firstWhere((r) => r.name == role).id,
        id: userId ?? "",
        locationId: locations
            .firstWhere((location) => location.name == locationId)
            .id,
      );
      if (userId == null) {
        await _repository.addUser(user: user);
      } else {
        // await _repository.updateUser(
        //   userId: userId!,
        //   username: username,
        //   password: password,
        //   name: name,
        // );
      }
      userId = null;
      await fetchUsers();
      emit(
        UsersActionSuccess(
          'تم إنشاء الموظف بنجاح، ويمكنه تسجيل الدخول الآن باستخدام البيانات التي أدخلتها.',
        ),
      );
    } catch (e) {
      print("Save user failed with error: $e");
      emit(UsersError("فشل في حفظ المستخدم"));
    }
  }

  fetchUsers() async {
    emit(UsersLoading());
    String? failureMessage;

    try {
      List dataGet = await _repository.fetchUsers();
      users = dataGet.map((data) => UserModel.fromJson(data)).toList();
    } catch (e) {
      print("Fetch users failed with error: $e");
      failureMessage = "فشل في جلب المستخدمين";
    }

    try {
      List dataGet = await _repository.fetchStoreLocations();
      locations = dataGet.map((data) => LocationModel.fromJson(data)).toList();
    } catch (e) {
      print("Fetch store locations failed with error: $e");
      failureMessage = failureMessage == null
          ? "فشل في جلب مواقع المتجر"
          : "$failureMessage، وفشل في جلب مواقع المتجر";
    }

    if (failureMessage != null) {
      emit(UsersError(failureMessage));
      return;
    }

    emit(UsersSuccess());
  }

  selectUser(UserModel user) {
    userId = user.id;
    emit(UsersLoaded());
  }

  clearSelection() {
    userId = null;
    emit(UsersLoaded());
  }
}
