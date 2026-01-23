import Palette
import PhotosUI
import UIKit

final class PaletteViewController: UIViewController {

    private lazy var imageView: UIImageView = {
        let result = UIImageView()
        result.isUserInteractionEnabled = true
        result.translatesAutoresizingMaskIntoConstraints = false
        result.contentMode = .center
        return result
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = .zero
        layout.minimumInteritemSpacing = .zero
        let result = UICollectionView(frame: .zero, collectionViewLayout: layout)
        result.register(SwatchCell.self, forCellWithReuseIdentifier: SwatchCell.identifier)
        result.dataSource = self
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    private var palette: Palette? {
        didSet {
            collectionView.reloadData()
            collectionView.flashScrollIndicators()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        imageView.image = UIImage.withText("Tap to select image", attributes: [
            .font: UIFont.systemFont(ofSize: 16.0)
        ])

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onImageTapped))
        imageView.addGestureRecognizer(tapGestureRecognizer)

        view.addSubview(imageView)
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.25),

            collectionView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16.0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(
            width: view.bounds.width / 2,
            height: 100
        )
    }

    @objc private func onImageTapped() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images, .livePhotos])
        let viewController = PHPickerViewController(configuration: configuration)
        viewController.delegate = self
        present(viewController, animated: true)
    }
}

extension PaletteViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        palette?.swatches.count ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SwatchCell.identifier, for: indexPath) as! SwatchCell
        if let swatch = palette?.swatches[indexPath.item] {
            cell.configure(with: swatch)
        }
        return cell
    }
}

extension PaletteViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else {
            return
        }

        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (reading: NSItemProviderReading?, error: (any Error)?) in
                guard let image = reading as? UIImage else { return }
                Palette.from(image: image).build { palette in
                    guard let self else { return }
                    self.palette = palette
                    self.imageView.contentMode = .scaleAspectFit
                    self.imageView.image = image
                }
            }
        }
    }
}
