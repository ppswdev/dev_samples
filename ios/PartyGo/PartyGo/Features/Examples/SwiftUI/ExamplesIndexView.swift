//
//  ExamplesIndex.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct ExamplesIndexView: View {
    var body: some View {
        NavigationView {
            List {
                // 视图布局组件
                Section("Basic: 视图布局组件") {
                    NavigationLink("Text", destination: TextExampleView())
                    NavigationLink("Image", destination: ImageExampleView())
                    NavigationLink("Button", destination: ButtonExampleView())
                    NavigationLink("TextField", destination: TextFieldExampleView())
                    NavigationLink("TextEditor", destination: TextEditorExampleView())
                    NavigationLink("Toggle", destination: ToggleExampleView())
                    NavigationLink("Picker", destination: PickerExampleView())
                    NavigationLink("Slider", destination: SliderExampleView())
                    NavigationLink("ProgressView", destination: ProgressViewExampleView())
                    NavigationLink("Label", destination: LabelExampleView())
                    NavigationLink("Group", destination: GroupExampleView())
                    NavigationLink("Divider", destination: DividerExampleView())
                    NavigationLink("Spacer", destination: SpacerExampleView())
                    NavigationLink("Color", destination: ColorExampleView())
                }

                // 导航路由
                Section("Navigation: 导航路由") {
                    NavigationLink("NavigationView", destination: NavigationExampleView())
                    NavigationLink("TabView", destination: TabViewExampleView())
                    NavigationLink("Sheet", destination: SheetExampleView())
                    NavigationLink("FullScreenCover", destination: FullScreenCoverExampleView())
                }
                
                // 动画过渡
                Section("Animation: 动画过渡") {
                    NavigationLink("基础动画", destination: BasicAnimationExampleView())
                    NavigationLink("转场动画", destination: TransitionExampleView())
                    NavigationLink("关键帧动画", destination: KeyframeAnimationExampleView())
                }
                
                // 列表数据
                Section("ListData: 列表数据") {
                    NavigationLink("List", destination: ListExampleView())
                    NavigationLink("LazyVStack", destination: LazyVStackExampleView())
                    NavigationLink("LazyHStack", destination: LazyHStackExampleView())
                    NavigationLink("ScrollView", destination: ScrollViewExampleView())
                }
                
                // 自定义视图和修饰符
                Section("CustomViews: 自定义视图和修饰符") {
                    NavigationLink("自定义修饰符", destination: CustomModifierExampleView())
                    NavigationLink("ViewBuilder", destination: ViewBuilderExampleView())
                    NavigationLink("Shape", destination: ShapeExampleView())
                }
                
                // 手势和交互
                Section("Gestures: 手势和交互") {
                    NavigationLink("TapGesture", destination: TapGestureExampleView())
                    NavigationLink("DragGesture", destination: DragGestureExampleView())
                    NavigationLink("LongPressGesture", destination: LongPressGestureExampleView())
                }
                
                // 生命周期和事件处理
                Section("Lifecycle: 生命周期和事件处理") {
                    NavigationLink("onAppear/onDisappear", destination: LifecycleExampleView())
                    NavigationLink("onReceive", destination: OnReceiveExampleView())
                    NavigationLink("Timer", destination: TimerExampleView())
                }
                
                // 主题和样式
                Section("Theme: 主题和样式") {
                    NavigationLink("自定义主题", destination: CustomThemeExampleView())
                    NavigationLink("动态颜色", destination: DynamicColorExampleView())
                    NavigationLink("我的主题", destination: MyThemeColorsExampleView())
                    NavigationLink("弥散光渐变主题", destination: GradientThemeExampleView())
                }
                
                // 错误处理和调试
                Section("ErrorHandling: 错误处理和调试") {
                    NavigationLink("错误处理", destination: ErrorHandlingExampleView())
                    NavigationLink("调试工具", destination: DebugToolsExampleView())
                }
                
                // 状态管理
                Section("StateManagement: 状态管理") {
                    NavigationLink("@State", destination: StateExampleView())
                    NavigationLink("@Binding", destination: BindingExampleView())
                    NavigationLink("@ObservedObject", destination: ObservedObjectExampleView())
                    NavigationLink("@StateObject", destination: StateObjectExampleView())
                    NavigationLink("@EnvironmentObject", destination: EnvironmentObjectExampleView())
                    NavigationLink("环境值", destination: EnvironmentExampleView())
                }
            }
            .navigationTitle("SwiftUI入门到精通")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ExamplesIndexView()
}
