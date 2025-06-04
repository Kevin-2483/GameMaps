import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:r6box/services/virtual_file_system/vfs_permission_system.dart';
import 'package:r6box/services/virtual_file_system/vfs_protocol.dart';
import 'package:r6box/services/virtual_file_system/virtual_file_system.dart';

void main() {
  group('VFS Permission System Tests', () {
    late VirtualFileSystem vfs;
    late VfsPermissionManager permissionManager;

    setUpAll(() async {
      // 初始化测试数据库工厂
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      vfs = VirtualFileSystem();
      permissionManager = VfsPermissionManager();

      // 初始化VFS
      await vfs.initialize();
      await permissionManager.initialize();

      // 挂载测试文件系统
      vfs.mount('r6box', 'test_permissions');

      // 为测试集合根目录设置默认权限
      await permissionManager.setPermissions(
        'indexeddb://r6box/test_permissions/',
        VfsPermissionMask.defaultUser,
      );
    });
    setUp(() async {
      // 在每个测试之前清理测试集合
      await vfs.clearCollection('r6box', 'test_permissions');

      // 清理权限缓存
      permissionManager.clearCache();

      // 重新设置根目录权限
      await permissionManager.setPermissions(
        'indexeddb://r6box/test_permissions/',
        VfsPermissionMask.defaultUser,
      );
    });

    test('系统保护路径应该有系统保护权限', () async {
      // 测试 .initialized 文件的系统保护
      final initPermissions = await permissionManager.getPermissions(
        'indexeddb://r6box/fs/.initialized',
      );

      expect(initPermissions.isSystemProtected, true);
      expect(initPermissions.userPermissions & VfsPermission.write, 0);
    });

    test('挂载点应该有系统保护权限', () async {
      // 测试 mnt/ 目录的系统保护
      final mntPermissions = await permissionManager.getPermissions(
        'indexeddb://r6box/fs/mnt/',
      );

      expect(mntPermissions.isSystemProtected, true);
      expect(mntPermissions.userPermissions & VfsPermission.write, 0);
    });

    test('用户创建的文件应该有默认用户权限', () async {
      // 创建测试文件
      final testPath = 'indexeddb://r6box/test_permissions/test_file.txt';
      await vfs.writeTextFile(testPath, 'Test content');

      // 检查权限
      final permissions = await permissionManager.getPermissions(testPath);
      expect(
        permissions.userPermissions & VfsPermission.read,
        VfsPermission.read,
      );
      expect(
        permissions.userPermissions & VfsPermission.write,
        VfsPermission.write,
      );
      expect(permissions.isSystemProtected, false);
    });

    test('权限设置和获取应该正常工作', () async {
      final testPath = 'indexeddb://r6box/test_permissions/permission_test.txt';
      await vfs.writeTextFile(testPath, 'Permission test content');

      // 设置自定义权限
      final customPermissions = VfsPermissionMask(
        userPermissions: VfsPermission.read, // 只读
        groupPermissions: VfsPermission.none,
        otherPermissions: VfsPermission.none,
      );

      await permissionManager.setPermissions(testPath, customPermissions);

      // 验证权限设置
      final retrievedPermissions = await permissionManager.getPermissions(
        testPath,
      );
      expect(retrievedPermissions.userPermissions, VfsPermission.read);
      expect(retrievedPermissions.groupPermissions, VfsPermission.none);
      expect(retrievedPermissions.otherPermissions, VfsPermission.none);
    });

    test('权限检查方法应该正常工作', () async {
      final testPath = 'indexeddb://r6box/test_permissions/check_test.txt';
      await vfs.writeTextFile(testPath, 'Check test content');

      // 设置只读权限
      await permissionManager.setPermissions(
        testPath,
        VfsPermissionMask(
          userPermissions: VfsPermission.read,
          groupPermissions: VfsPermission.none,
          otherPermissions: VfsPermission.none,
        ),
      );

      // 测试权限检查
      expect(await permissionManager.canRead(testPath), true);
      expect(await permissionManager.canWrite(testPath), false);
      expect(await permissionManager.canDelete(testPath), false);
    });

    test('系统保护文件不能删除', () async {
      // 尝试删除系统保护文件应该被拒绝
      expect(
        await permissionManager.canDelete('indexeddb://r6box/fs/.initialized'),
        false,
      );
      expect(
        await permissionManager.canDelete('indexeddb://r6box/fs/mnt/'),
        false,
      );
    });

    test('权限继承应该正常工作', () async {
      // 创建父目录
      final parentPath = 'indexeddb://r6box/test_permissions/parent_dir';
      await vfs.createDirectory(parentPath);

      // 设置父目录权限
      await permissionManager.setPermissions(
        parentPath,
        VfsPermissionMask(
          userPermissions: VfsPermission.read,
          groupPermissions: VfsPermission.read,
          otherPermissions: VfsPermission.none,
        ),
      );

      // 创建子文件并应用继承
      final childPath =
          'indexeddb://r6box/test_permissions/parent_dir/child_file.txt';
      await vfs.createFileWithInheritance(
        childPath,
        VfsFileContent(data: Uint8List.fromList('child content'.codeUnits)),
        inheritancePolicy: VfsInheritancePolicy.inheritancePolicy,
      );

      // 检查继承的权限
      final childPermissions = await permissionManager.getPermissions(
        childPath,
      );
      expect(childPermissions.userPermissions, VfsPermission.read);
      expect(childPermissions.groupPermissions, VfsPermission.read);
      expect(childPermissions.otherPermissions, VfsPermission.none);
    });

    test('权限过滤应该正常工作', () async {
      // 创建多个文件，设置不同权限
      final file1 = 'indexeddb://r6box/test_permissions/readable.txt';
      final file2 = 'indexeddb://r6box/test_permissions/unreadable.txt';

      await vfs.writeTextFile(file1, 'readable content');
      await vfs.writeTextFile(file2, 'unreadable content');

      // 设置权限
      await permissionManager.setPermissions(
        file1,
        VfsPermissionMask.defaultUser,
      );
      await permissionManager.setPermissions(
        file2,
        VfsPermissionMask(
          userPermissions: VfsPermission.none,
          groupPermissions: VfsPermission.none,
          otherPermissions: VfsPermission.none,
        ),
      );

      // 获取所有文件
      final allFiles = await vfs.listDirectory(
        'indexeddb://r6box/test_permissions',
      );

      // 过滤只可读文件
      final readableFiles = await permissionManager.filterByPermissions(
        allFiles,
        requiredPermission: VfsPermission.read,
      );

      // 验证过滤结果
      expect(readableFiles.any((f) => f.name == 'readable.txt'), true);
      expect(readableFiles.any((f) => f.name == 'unreadable.txt'), false);
    });
  });
}
