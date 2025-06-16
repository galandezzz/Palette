extension Color {

    convenience init(_ color: ColorDescriptor) {
        self.init(
            red: CGFloat(color.red) / 255.0,
            green: CGFloat(color.green) / 255.0,
            blue: CGFloat(color.blue) / 255.0,
            alpha: 1.0
        )
    }
}
