import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/util/theme_extension.dart';
import 'package:appflowy/workspace/application/sidebar/folder/folder_bloc.dart';
import 'package:appflowy/workspace/application/sidebar/space/space_bloc.dart';
import 'package:appflowy/workspace/application/view/view_bloc.dart';
import 'package:appflowy/workspace/application/view/view_ext.dart';
import 'package:appflowy/workspace/presentation/home/home_sizes.dart';
import 'package:appflowy/workspace/presentation/home/menu/sidebar/space/_extension.dart';
import 'package:appflowy/workspace/presentation/home/menu/sidebar/space/sidebar_space_menu.dart';
import 'package:appflowy/workspace/presentation/home/menu/sidebar/space/space_icon.dart';
import 'package:appflowy/workspace/presentation/home/menu/view/view_item.dart';
import 'package:appflowy_backend/protobuf/flowy-folder/protobuf.dart';
import 'package:appflowy_backend/protobuf/flowy-folder/view.pb.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flowy_infra_ui/style_widget/hover.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_platform/universal_platform.dart';

class SpacePermissionSwitch extends StatefulWidget {
  const SpacePermissionSwitch({
    super.key,
    required this.onPermissionChanged,
    this.spacePermission,
    this.showArrow = false,
  });

  final SpacePermission? spacePermission;
  final void Function(SpacePermission permission) onPermissionChanged;
  final bool showArrow;

  @override
  State<SpacePermissionSwitch> createState() => _SpacePermissionSwitchState();
}

class _SpacePermissionSwitchState extends State<SpacePermissionSwitch> {
  late SpacePermission spacePermission =
      widget.spacePermission ?? SpacePermission.publicToAll;
  final popoverController = PopoverController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlowyText.regular(
          LocaleKeys.space_permission.tr(),
          fontSize: 14.0,
          color: Theme.of(context).hintColor,
          figmaLineHeight: 18.0,
        ),
        const VSpace(6.0),
        AppFlowyPopover(
          controller: popoverController,
          direction: PopoverDirection.bottomWithCenterAligned,
          constraints: const BoxConstraints(maxWidth: 500),
          offset: const Offset(0, 4),
          margin: EdgeInsets.zero,
          popupBuilder: (_) => _buildPermissionButtons(),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: context.enableBorderColor),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: SpacePermissionButton(
              showArrow: true,
              permission: spacePermission,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionButtons() {
    return SizedBox(
      width: 452,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpacePermissionButton(
            permission: SpacePermission.publicToAll,
            onTap: () => _onPermissionChanged(SpacePermission.publicToAll),
          ),
          SpacePermissionButton(
            permission: SpacePermission.private,
            onTap: () => _onPermissionChanged(SpacePermission.private),
          ),
        ],
      ),
    );
  }

  void _onPermissionChanged(SpacePermission permission) {
    widget.onPermissionChanged(permission);

    setState(() {
      spacePermission = permission;
    });

    popoverController.close();
  }
}

class SpacePermissionButton extends StatelessWidget {
  const SpacePermissionButton({
    super.key,
    required this.permission,
    this.onTap,
    this.showArrow = false,
  });

  final SpacePermission permission;
  final VoidCallback? onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final (title, desc, icon) = switch (permission) {
      SpacePermission.publicToAll => (
          LocaleKeys.space_publicPermission.tr(),
          LocaleKeys.space_publicPermissionDescription.tr(),
          FlowySvgs.space_permission_public_s
        ),
      SpacePermission.private => (
          LocaleKeys.space_privatePermission.tr(),
          LocaleKeys.space_privatePermissionDescription.tr(),
          FlowySvgs.space_permission_private_s
        ),
    };

    return FlowyButton(
      margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      radius: showArrow ? BorderRadius.circular(10) : BorderRadius.zero,
      iconPadding: 16.0,
      leftIcon: FlowySvg(icon),
      leftIconSize: const Size.square(20),
      rightIcon: showArrow
          ? const FlowySvg(FlowySvgs.space_permission_dropdown_s)
          : null,
      borderColor: Theme.of(context).isLightMode
          ? const Color(0x1E171717)
          : const Color(0xFF3A3F49),
      text: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlowyText.regular(title),
          const VSpace(4.0),
          FlowyText.regular(
            desc,
            fontSize: 12.0,
            color: Theme.of(context).hintColor,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class SpaceCancelOrConfirmButton extends StatelessWidget {
  const SpaceCancelOrConfirmButton({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    required this.confirmButtonName,
    this.confirmButtonColor,
    this.confirmButtonBuilder,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final String confirmButtonName;
  final Color? confirmButtonColor;
  final WidgetBuilder? confirmButtonBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AFOutlinedTextButton.normal(
          size: UniversalPlatform.isDesktop ? AFButtonSize.m : AFButtonSize.l,
          text: LocaleKeys.button_cancel.tr(),
          textStyle: theme.textStyle.body.standard(
            color: theme.textColorScheme.primary,
          ),
          onTap: onCancel,
        ),
        const HSpace(12.0),
        if (confirmButtonBuilder != null) ...[
          confirmButtonBuilder!(context),
        ] else ...[
          DecoratedBox(
            decoration: ShapeDecoration(
              color:
                  confirmButtonColor ?? Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: FlowyButton(
              useIntrinsicWidth: true,
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
              radius: BorderRadius.circular(8),
              text: FlowyText.regular(
                confirmButtonName,
                lineHeight: 1.0,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onTap: onConfirm,
            ),
          ),
        ],
      ],
    );
  }
}

class SpaceOkButton extends StatelessWidget {
  const SpaceOkButton({
    super.key,
    required this.onConfirm,
    required this.confirmButtonName,
    this.confirmButtonColor,
  });

  final VoidCallback onConfirm;
  final String confirmButtonName;
  final Color? confirmButtonColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PrimaryRoundedButton(
          text: confirmButtonName,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0),
          radius: 8.0,
          onTap: onConfirm,
        ),
      ],
    );
  }
}

enum ConfirmPopupStyle {
  onlyOk,
  cancelAndOk,
}

class ConfirmPopupColor {
  static Color titleColor(BuildContext context) {
    return AppFlowyTheme.of(context).textColorScheme.primary;
  }

  static Color descriptionColor(BuildContext context) {
    return AppFlowyTheme.of(context).textColorScheme.primary;
  }
}

class ConfirmPopup extends StatefulWidget {
  const ConfirmPopup({
    super.key,
    this.style = ConfirmPopupStyle.cancelAndOk,
    required this.title,
    required this.description,
    required this.onConfirm,
    this.onCancel,
    this.confirmLabel,
    this.titleStyle,
    this.descriptionStyle,
    this.confirmButtonColor,
    this.confirmButtonBuilder,
    this.child,
    this.closeOnAction = true,
    this.showCloseButton = true,
    this.enableKeyboardListener = true,
  });

  final String title;
  final TextStyle? titleStyle;
  final String description;
  final TextStyle? descriptionStyle;
  final void Function(BuildContext context) onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;
  final ConfirmPopupStyle style;

  /// The label of the confirm button.
  ///
  /// Defaults to 'Delete' for [ConfirmPopupStyle.cancelAndOk] style.
  /// Defaults to 'Ok' for [ConfirmPopupStyle.onlyOk] style.
  ///
  final String? confirmLabel;

  /// Allows to add a child to the popup.
  ///
  /// This is useful when you want to add more content to the popup.
  /// The child will be placed below the description.
  ///
  final Widget? child;

  /// Decides whether the popup should be closed when the confirm button is clicked.
  /// Defaults to true.
  ///
  final bool closeOnAction;

  /// Show close button.
  /// Defaults to true.
  ///
  final bool showCloseButton;

  /// Enable keyboard listener.
  /// Defaults to true.
  ///
  final bool enableKeyboardListener;

  /// Allows to build a custom confirm button.
  ///
  final WidgetBuilder? confirmButtonBuilder;

  @override
  State<ConfirmPopup> createState() => _ConfirmPopupState();
}

class _ConfirmPopupState extends State<ConfirmPopup> {
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    return KeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (widget.enableKeyboardListener) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          } else if (event is KeyUpEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            widget.onConfirm(context);
            if (widget.closeOnAction) {
              Navigator.of(context).pop();
            }
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(theme.borderRadius.xl),
          color: AppFlowyTheme.of(context).surfaceColorScheme.primary,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.xxl,
          vertical: theme.spacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            if (widget.description.isNotEmpty) ...[
              VSpace(theme.spacing.l),
              _buildDescription(),
            ],
            if (widget.child != null) ...[
              const VSpace(12),
              widget.child!,
            ],
            VSpace(theme.spacing.xxl),
            _buildStyledButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final theme = AppFlowyTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.title,
            style: widget.titleStyle ??
                theme.textStyle.heading4.prominent(
                  color: ConfirmPopupColor.titleColor(context),
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const HSpace(6.0),
        if (widget.showCloseButton) ...[
          AFGhostButton.normal(
            size: AFButtonSize.s,
            padding: EdgeInsets.all(theme.spacing.xs),
            onTap: () => Navigator.of(context).pop(),
            builder: (context, isHovering, disabled) => FlowySvg(
              FlowySvgs.password_close_m,
              size: const Size.square(20),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription() {
    if (widget.description.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = AppFlowyTheme.of(context);

    return Text(
      widget.description,
      style: widget.descriptionStyle ??
          theme.textStyle.body.standard(
            color: ConfirmPopupColor.descriptionColor(context),
          ),
      maxLines: 5,
    );
  }

  Widget _buildStyledButton(BuildContext context) {
    switch (widget.style) {
      case ConfirmPopupStyle.onlyOk:
        if (widget.confirmButtonBuilder != null) {
          return widget.confirmButtonBuilder!(context);
        }

        return SpaceOkButton(
          onConfirm: () {
            widget.onConfirm(context);
            if (widget.closeOnAction) {
              Navigator.of(context).pop();
            }
          },
          confirmButtonName: widget.confirmLabel ?? LocaleKeys.button_ok.tr(),
          confirmButtonColor: widget.confirmButtonColor ??
              Theme.of(context).colorScheme.primary,
        );
      case ConfirmPopupStyle.cancelAndOk:
        return SpaceCancelOrConfirmButton(
          onCancel: () {
            widget.onCancel?.call();
            Navigator.of(context).pop();
          },
          onConfirm: () {
            widget.onConfirm(context);
            if (widget.closeOnAction) {
              Navigator.of(context).pop();
            }
          },
          confirmButtonName:
              widget.confirmLabel ?? LocaleKeys.space_delete.tr(),
          confirmButtonColor:
              widget.confirmButtonColor ?? Theme.of(context).colorScheme.error,
          confirmButtonBuilder: widget.confirmButtonBuilder,
        );
    }
  }
}

class SpacePopup extends StatelessWidget {
  const SpacePopup({
    super.key,
    this.height,
    this.useIntrinsicWidth = true,
    this.expand = false,
    required this.showCreateButton,
    required this.child,
  });

  final bool showCreateButton;
  final bool useIntrinsicWidth;
  final bool expand;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? HomeSizes.workspaceSectionHeight,
      child: AppFlowyPopover(
        constraints: const BoxConstraints(maxWidth: 260),
        direction: PopoverDirection.bottomWithLeftAligned,
        clickHandler: PopoverClickHandler.gestureDetector,
        offset: const Offset(0, 4),
        popupBuilder: (_) => BlocProvider.value(
          value: context.read<SpaceBloc>(),
          child: SidebarSpaceMenu(
            showCreateButton: showCreateButton,
          ),
        ),
        child: FlowyButton(
          useIntrinsicWidth: useIntrinsicWidth,
          expand: expand,
          margin: const EdgeInsets.only(left: 3.0, right: 4.0),
          iconPadding: 10.0,
          text: child,
        ),
      ),
    );
  }
}

class CurrentSpace extends StatelessWidget {
  const CurrentSpace({
    super.key,
    this.onTapBlankArea,
    required this.space,
    this.isHovered = false,
  });

  final ViewPB space;
  final VoidCallback? onTapBlankArea;
  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SpaceIcon(
          dimension: 22,
          space: space,
          svgSize: 12,
          cornerRadius: 8.0,
        ),
        const HSpace(10),
        Flexible(
          child: FlowyText.medium(
            space.name,
            fontSize: 14.0,
            figmaLineHeight: 18.0,
            overflow: TextOverflow.ellipsis,
            color: isHovered ? Theme.of(context).colorScheme.onSurface : null,
          ),
        ),
        const HSpace(4.0),
        FlowySvg(
          context.read<SpaceBloc>().state.isExpanded
              ? FlowySvgs.workspace_drop_down_menu_show_s
              : FlowySvgs.workspace_drop_down_menu_hide_s,
          color: isHovered ? Theme.of(context).colorScheme.onSurface : null,
        ),
      ],
    );

    if (onTapBlankArea != null) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: FlowyHover(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: child,
              ),
            ),
          ),
          Expanded(
            child: FlowyTooltip(
              message: LocaleKeys.space_movePageToSpace.tr(),
              child: GestureDetector(
                onTap: onTapBlankArea,
              ),
            ),
          ),
        ],
      );
    }

    return child;
  }
}

class SpacePages extends StatelessWidget {
  const SpacePages({
    super.key,
    required this.space,
    required this.isHovered,
    required this.isExpandedNotifier,
    required this.onSelected,
    this.rightIconsBuilder,
    this.disableSelectedStatus = false,
    this.onTertiarySelected,
    this.shouldIgnoreView,
  });

  final ViewPB space;
  final ValueNotifier<bool> isHovered;
  final PropertyValueNotifier<bool> isExpandedNotifier;
  final bool disableSelectedStatus;
  final ViewItemRightIconsBuilder? rightIconsBuilder;
  final ViewItemOnSelected onSelected;
  final ViewItemOnSelected? onTertiarySelected;
  final IgnoreViewType Function(ViewPB view)? shouldIgnoreView;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ViewBloc(view: space)..add(const ViewEvent.initial()),
      child: BlocBuilder<ViewBloc, ViewState>(
        builder: (context, state) {
          // filter the child views that should be ignored
          List<ViewPB> childViews = state.view.childViews;
          if (shouldIgnoreView != null) {
            childViews = childViews
                .where((v) => shouldIgnoreView!(v) != IgnoreViewType.hide)
                .toList();
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: childViews
                .map(
                  (view) => ViewItem(
                    key: ValueKey('${space.id} ${view.id}'),
                    spaceType:
                        space.spacePermission == SpacePermission.publicToAll
                            ? FolderSpaceType.public
                            : FolderSpaceType.private,
                    isFirstChild: view.id == childViews.first.id,
                    view: view,
                    level: 0,
                    leftPadding: HomeSpaceViewSizes.leftPadding,
                    isFeedback: false,
                    isHovered: isHovered,
                    enableRightClickContext: !disableSelectedStatus,
                    disableSelectedStatus: disableSelectedStatus,
                    isExpandedNotifier: isExpandedNotifier,
                    rightIconsBuilder: rightIconsBuilder,
                    onSelected: onSelected,
                    onTertiarySelected: onTertiarySelected,
                    shouldIgnoreView: shouldIgnoreView,
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class SpaceSearchField extends StatefulWidget {
  const SpaceSearchField({
    super.key,
    required this.width,
    required this.onSearch,
  });

  final double width;
  final void Function(BuildContext context, String text) onSearch;

  @override
  State<SpaceSearchField> createState() => _SpaceSearchFieldState();
}

class _SpaceSearchFieldState extends State<SpaceSearchField> {
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: widget.width,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1.20,
            strokeAlign: BorderSide.strokeAlignOutside,
            color: Color(0xFF00BCF0),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: CupertinoSearchTextField(
        onChanged: (text) => widget.onSearch(context, text),
        padding: EdgeInsets.zero,
        focusNode: focusNode,
        placeholder: LocaleKeys.search_label.tr(),
        prefixIcon: const FlowySvg(FlowySvgs.magnifier_s),
        prefixInsets: const EdgeInsets.only(left: 12.0, right: 8.0),
        suffixIcon: const Icon(Icons.close),
        suffixInsets: const EdgeInsets.only(right: 8.0),
        itemSize: 16.0,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        placeholderStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.w400,
            ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }
}
