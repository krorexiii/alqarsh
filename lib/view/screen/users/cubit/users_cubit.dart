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
      final String email = username.trim();
      UserModel user = UserModel(
        username: email,
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
          'تم إنشاء الموظف بنجاح، وسيصل بريد تأكيد إلى $email لتفعيل الحساب.',
        ),
      );
    } catch (e) {
      print("Save user failed with error: $e");
      emit(UsersError("فشل في حفظ المستخدم"));
    }
  }

  fetchUsers() async {
    emit(UsersLoading());
    try {
      List dataGet = await _repository.fetchUsers();
      users = dataGet.map((data) => UserModel.fromJson(data)).toList();

      dataGet = await _repository.fetchLocations();
      locations = dataGet.map((data) => LocationModel.fromJson(data)).toList();
      emit(UsersSuccess());
    } catch (e) {
      print("Fetch users failed with error: $e");
      emit(UsersError("فشل في جلب المستخدمين"));
    }
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
