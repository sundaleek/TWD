import UIKit
import Player
import Photos

class DetailVC: UIViewController {

    var player: Player!
    var url: URL?

    var download: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Download Video", for: .normal)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.player = Player()

        let w = UIScreen.main.bounds.width
        self.player.view.frame = CGRect(x: 0, y: 0, width: w, height: w)

        self.addChild(self.player)
        self.view.addSubview(self.player.view)
        self.player.didMove(toParent: self)
        self.player.url = url
        player.fillMode = .resizeAspect
        player.playFromBeginning()

        view.addSubview(download)
        download.snp.makeConstraints { (m) in
            m.top.equalTo(player.view.snp.bottom).inset(-20)
            m.centerX.equalToSuperview()
        }
        download.addTarget(self, action: #selector(onDownload), for: .touchUpInside)
    }

    @objc func onDownload() {

        DispatchQueue.global(qos: .background).async { [weak self] in
            if let url = self?.url,
                let urlData = NSData(contentsOf: url) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/tempFile.mp4"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if completed {
                            after(0) { [weak self] in
                                self?.showStatusAlert("Video is saved!")
                            }
                        }
                    }
                }
            }
        }
    }

    private func showStatusAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        after(1) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}

func after(_ seconds: TimeInterval, block: @escaping () -> Void) {
    let delay_SECONDS = DispatchTime.now() + seconds
    DispatchQueue.main.asyncAfter(deadline: delay_SECONDS) {
        block()
    }
}
