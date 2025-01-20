## 📱 **SoberMate - 절주를 도와주는 스마트 동반자**

### 📝 **프로젝트 개요**

**SoberMate**는 현대인들이 자신의 음주 습관을 체계적으로 관리하고, 목표 달성에 동기부여를 받을 수 있도록 설계된 iOS 애플리케이션입니다. 이 앱은 사용자가 절주 목표를 설정하고, 음주 기록을 체계적으로 관리하며, 커뮤니티를 통해 서로의 경험을 공유할 수 있는 플랫폼을 제공합니다. **SoberMate**는 사용자 경험을 최우선으로 고려하여 직관적인 UI/UX 디자인과 최신 iOS 기술을 접목시켰습니다.

### 🎯 **주요 기능**

- **목표 설정 및 추적**: 사용자는 자신의 절주 목표를 설정하고, 매일의 음주량을 기록하여 목표 달성 상황을 실시간으로 추적할 수 있습니다. 목표 달성에 따른 보상 시스템을 도입하여 사용자가 지속적인 동기부여를 받을 수 있도록 설계했습니다.
- **음주 기록 관리**: 사용자가 음주량, 음주의 종류, 장소, 느낌 등을 기록하고 분석할 수 있는 기능을 제공하여, 자신의 음주 습관을 체계적으로 관리할 수 있습니다.
- **커뮤니티 기능**: 사용자는 커뮤니티 게시판을 통해 자신의 경험을 공유하고, 다른 사용자의 경험을 통해 영감을 얻을 수 있습니다. 이 기능을 통해 사용자 간의 유대감을 강화하고, 공동의 목표를 가진 사용자들이 서로를 지원할 수 있도록 했습니다.
- **감정 기록 및 통계**: 사용자는 일기 기능을 통해 자신의 감정을 기록할 수 있으며, 이 데이터를 기반으로 자신의 감정 상태와 음주 습관 간의 상관관계를 분석하는 통계 기능을 제공합니다.
- **알림 및 리마인더**: 설정된 목표와 관련하여 사용자에게 알림을 보내어 목표를 잊지 않고 달성할 수 있도록 도와줍니다. 이를 통해 사용자가 지속적으로 자신의 목표에 집중할 수 있습니다.

### 💻 **기술 스택 및 구현 세부 사항**

- **Swift 및 SwiftUI**: 최신 iOS 개발 언어와 UI 프레임워크인 Swift와 SwiftUI를 활용하여 직관적이고 반응성이 뛰어난 사용자 인터페이스를 구현했습니다. 특히, SwiftUI의 선언적 UI 패러다임을 통해 간결하면서도 유지보수하기 쉬운 코드를 작성할 수 있었습니다.
- **Firebase**: Firebase Authentication, Firestore, Cloud Storage를 통합하여 사용자 인증, 실시간 데이터베이스 관리, 클라우드 저장소 등을 구현했습니다. 이를 통해 사용자 간의 데이터 동기화, 실시간 커뮤니티 게시판, 그리고 안전한 사용자 데이터 관리를 실현했습니다.
- **Combine 프레임워크**: 비동기 데이터 흐름과 상태 관리를 위해 Combine을 사용했습니다. Combine의 퍼블리셔/서브스크라이버 패턴을 통해 UI와 데이터 간의 바인딩을 효율적으로 처리하고, 비동기 작업에서 발생할 수 있는 복잡성을 줄였습니다.
- **CoreData**: 사용자 데이터를 로컬에 안전하게 저장하기 위해 CoreData를 사용했습니다. 긴급 연락처와 같은 중요한 정보는 오프라인 상태에서도 접근 가능하도록 구현하여 사용자 편의성을 높였습니다.
- **Google Sign-In 및 Apple Sign-In**: 간편한 사용자 로그인 경험을 제공하기 위해 Google과 Apple의 OAuth 인증을 통합했습니다. 이를 통해 사용자는 다양한 소셜 계정을 통해 앱에 쉽게 접근할 수 있습니다.

### 🛠 **디자인 패턴 및 아키텍처**

- **MVVM (Model-View-ViewModel)**: 앱의 유지보수성과 테스트 용이성을 높이기 위해 MVVM 디자인 패턴을 적용했습니다. 이 패턴을 통해 View와 Model 간의 명확한 역할 분리를 유지하면서도, ViewModel을 통해 데이터와 UI 간의 상호작용을 효율적으로 관리했습니다.
- **의존성 주입 (Dependency Injection)**: ViewModel과 서비스 간의 의존성을 관리하기 위해 의존성 주입을 사용했습니다. 이 접근법은 테스트 용이성을 높이고, 코드의 유연성과 재사용성을 강화하는 데 중점을 두었습니다.
- **데이터 바인딩**: SwiftUI와 Combine을 사용하여 View와 ViewModel 간의 데이터 바인딩을 구현했습니다. 이를 통해 데이터의 변경 사항이 즉시 UI에 반영되도록 하여, 사용자에게 실시간 피드백을 제공하는 사용자 경험을 구현했습니다.

### 📈 **개발 과정에서의 역할 및 기여**

- **프로젝트 전체 설계 및 구현**: 초기 기획 단계부터 앱의 전체 아키텍처 설계 및 주요 기능 구현을 주도했습니다. Firebase와 SwiftUI를 결합하여 실시간 데이터 동기화, 직관적인 UI/UX, 사용자 편의성을 높이는 기능들을 성공적으로 구현했습니다.
- **Firebase 연동 및 관리**: Firebase를 활용해 사용자 인증, 데이터 저장, 실시간 동기화 등의 기능을 구현했으며, 이를 통해 사용자 간의 원활한 데이터 공유와 커뮤니티 상호작용을 실현했습니다.
- **테스트 및 디버깅**: 단위 테스트를 작성하고, 다양한 시나리오에서 앱의 안정성을 검증했습니다. 또한, Firebase와 연동된 기능에서 발생할 수 있는 비동기 작업의 문제를 철저히 테스트하여 앱의 신뢰성을 확보했습니다.
- **유저 경험 중심의 개발**: 사용자 경험을 최우선으로 고려하여, 사용자가 직관적으로 앱을 사용할 수 있도록 UI/UX를 설계했습니다.  미래의 사용자의 피드백을 반영하여 지속적으로 개선 작업을 수행했습니다.

### 🚀 **프로젝트의 성과 및 의미**

**SoberMate**는 단순한 기록 관리 앱을 넘어, 사용자가 자신의 삶을 긍정적으로 변화시킬 수 있도록 돕는 강력한 도구입니다. 이 프로젝트를 통해 최신 iOS 개발 기술에 대한 이해를 심화시켰으며, 실시간 데이터 처리, 비동기 작업 관리, 사용자 중심 설계의 중요성을 깊이 체감할 수 있었습니다. SoberMate의 개발 경험은 저에게 개발자로서의 성장을 가져다주었으며, 앞으로의 프로젝트에서도 이러한 경험을 바탕으로 더 나은 결과물을 만들어나갈 자신감을 얻었습니다.

---

## **스크린샷**

### 메인화면

![IMG_5096.PNG](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9f35de7-0091-4a79-819a-501ef9435828/69c557ac-e2db-47db-8d98-1776078affe1/IMG_5096.png)

### **금주 목표 설정 화면**

![IMG_5086.PNG](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9f35de7-0091-4a79-819a-501ef9435828/22fdbffb-ba57-4f81-a775-8605a51b6d5c/IMG_5086.png)

### **음주 기록 관리 화면**

![IMG_5088.PNG](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9f35de7-0091-4a79-819a-501ef9435828/3d267ec8-3506-4afa-94b7-312ff9c4b020/IMG_5088.png)

### **감정 상태 추적 화면**

![IMG_5089.PNG](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9f35de7-0091-4a79-819a-501ef9435828/1b6facad-a846-42b4-ae64-257991f9b624/IMG_5089.png)

### **커뮤니티 게시판 화면**

![IMG_5090.PNG](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9f35de7-0091-4a79-819a-501ef9435828/f0589d1f-b433-4ad5-8464-3a5698933114/IMG_5090.png)

![IMG_5091.PNG](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9f35de7-0091-4a79-819a-501ef9435828/d49fd308-ee55-41b4-b06b-ca2ec92f0f1b/IMG_5091.png)

### 성취도 확인 화면

![IMG_5093.PNG](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9f35de7-0091-4a79-819a-501ef9435828/c7ec86b1-5e55-4780-b990-da3a4e803f5e/IMG_5093.png)

### 통계 화면

![IMG_37A8ADB0D0B1-1.jpeg](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9f35de7-0091-4a79-819a-501ef9435828/d5cd0bf3-301f-44eb-ab1d-a8b9c9988b73/IMG_37A8ADB0D0B1-1.jpeg)

### **긴급 연락처 관리 화면**

![IMG_5094.PNG](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9f35de7-0091-4a79-819a-501ef9435828/4d612dc0-3c0c-4615-8f97-dfcac511d550/IMG_5094.png)

![IMG_5095.PNG](https://prod-files-secure.s3.us-west-2.amazonaws.com/f9f35de7-0091-4a79-819a-501ef9435828/8bd617d9-0c5d-41dd-95f5-433f60487602/IMG_5095.png)

---

### 📌 **코드 스니펫 1: Firebase와 Combine을 활용한 실시간 데이터 바인딩**

```swift
FirebaseManager.shared.getNickname(userId: user.uid)
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            break
        case .failure(let error):
            print("Failed to get nickname: \(error.localizedDescription)")
        }
    }, receiveValue: { nickname in
        let newComment = Comment(
            content: self.commentContent,
            sender: nickname,
            createdAt: Date(),
            userId: user.uid
        )

        FirebaseManager.shared.saveComment(postId: postId, comment: newComment) { result in
            switch result {
            case .success:
                self.fetchComments()
                self.commentContent = ""
            case .failure(let error):
                print("Failed to save comment: \(error.localizedDescription)")
            }
        }
    })
    .store(in: &cancellables)

```

**설명**: 이 코드 스니펫은 Firebase와 Combine을 사용하여 비동기적으로 데이터를 가져오고, 이를 바탕으로 새로운 댓글을 생성한 후 Firebase에 저장하는 과정을 보여줍니다. `sink`를 사용하여 데이터를 비동기적으로 받아 처리하며, 에러 핸들링을 통해 사용자가 기대하는 결과를 제공하지 못했을 때의 상황도 관리합니다. Combine 프레임워크의 퍼블리셔/서브스크라이버 패턴을 활용하여 비동기 작업을 효율적으로 처리한 점이 돋보입니다.

---

### 📌 **코드 스니펫 2: MVVM 패턴을 적용한 ViewModel과 View의 데이터 바인딩**

```swift
@Published var drinkStats: [DrinkStat] = []
@Published var feelingStats: [FeelingStat] = []

func fetchStats(for timeFrame: String) {
    guard let userId = Auth.auth().currentUser?.uid else { return }

    FirebaseManager.shared.fetchDrinkStats(forUser: userId, for: timeFrame) { result in
        switch result {
        case .success(let stats):
            DispatchQueue.main.async {
                self.drinkStats = self.groupByDetails(stats: stats)
            }
        case .failure(let error):
            print("Failed to fetch drink stats: \(error)")
        }
    }

    FirebaseManager.shared.fetchFeelingStats(forUser: userId, for: timeFrame) { result in
        switch result {
        case .success(let stats):
            DispatchQueue.main.async {
                self.feelingStats = stats
            }
        case .failure(let error):
            print("Failed to fetch feeling stats: \(error)")
        }
    }
}

```

**설명**: 이 스니펫은 MVVM 패턴에서 ViewModel이 데이터 로딩 로직을 처리하는 방식을 보여줍니다. `@Published` 프로퍼티로 선언된 `drinkStats`와 `feelingStats`는 View와 바인딩되어 있어, 데이터가 업데이트되면 자동으로 UI에 반영됩니다. Firebase에서 데이터를 가져오고 이를 View에 반영하는 과정에서, 데이터 흐름의 명확성과 코드의 가독성을 높이기 위해 MVVM 패턴을 사용한 점이 강조됩니다.

---

### 📌 **코드 스니펫 3: CoreData를 활용한 로컬 데이터 저장**

```swift
func addContact() {
    let newContact = CDEmergencyContacts(context: viewContext)
    newContact.name = newName
    newContact.mobile = newPhoneNumber

    do {
        try viewContext.save()
        newName = ""
        newPhoneNumber = ""
    } catch {
        // Handle the error appropriately
        print("Failed to save contact: \(error.localizedDescription)")
    }
}

```

**설명**: 이 스니펫은 CoreData를 사용해 로컬 데이터베이스에 긴급 연락처를 저장하는 과정을 보여줍니다. 사용자가 입력한 데이터를 `NSManagedObjectContext`를 통해 CoreData에 저장하며, 데이터 저장 후 입력 필드를 초기화하는 방식으로 UX를 향상시켰습니다. CoreData의 강력한 로컬 데이터 관리 능력을 활용한 점을 강조할 수 있습니다.

---

### 📌 **코드 스니펫 4: SwiftUI를 사용한 직관적인 사용자 인터페이스 구현**

```swift
VStack(spacing: 20) {
    Text("SoberMate")
        .font(.system(size: 36, weight: .bold))
        .foregroundColor(.primary)
        .padding(.top, 60)

    Spacer()

    SignInWithAppleButton(.signIn, onRequest: { request in
        request.requestedScopes = [.fullName, .email]
    }, onCompletion: { result in
        switch result {
        case .success(let authResults):
            authViewModel.handleAuthorization(authResults)
        case .failure(let error):
            print("Authorization failed: \(error.localizedDescription)")
        }
    })
    .signInWithAppleButtonStyle(.black)
    .frame(height: 50)
    .cornerRadius(10)
    .padding(.horizontal, 40)

    Button(action: {
        authViewModel.signInWithGoogle()
    }) {
        HStack {
            Image("googleLogo")
                .resizable()
                .frame(width: 24, height: 24)
            Text("Sign In with Google")
                .font(.system(size: 18, weight: .medium))
        }
        .foregroundColor(.white)
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background(Color.blue)
        .cornerRadius(10)
    }
    .padding(.horizontal, 40)
}

```

**설명**: 이 스니펫은 SwiftUI를 사용해 직관적이고 반응성이 뛰어난 로그인 화면을 구현한 예시입니다. Apple과 Google 계정을 이용한 로그인 버튼을 사용자가 쉽게 접근할 수 있도록 배치했으며, SwiftUI의 `VStack`과 `Button` 등의 컴포넌트를 활용하여 깔끔한 UI를 구성했습니다. 사용자 중심의 인터페이스를 구현하는 데 중점을 두었습니다.

---

### 📌 **코드 스니펫 5: 사용자 데이터를 기반으로 통계를 시각화하는 Chart**

```swift
Chart(viewModel.feelingStats) { stat in
    LineMark(
        x: .value("Date", stat.date, unit: .day),
        y: .value("Feeling", stat.feeling)
    )
}
.frame(height: 200)
.padding()
.background(Color(UIColor.secondarySystemBackground))
.cornerRadius(10)
.shadow(radius: 5)

```

**설명**: 이 스니펫은 `Swift Charts`를 사용하여 사용자 감정 상태의 변화를 시각화하는 예시입니다. 데이터 모델과 Chart의 `LineMark`를 사용하여 날짜별 감정 점수를 표시하며, 사용자에게 유의미한 데이터를 시각적으로 전달하는 방법을 보여줍니다. 데이터의 시각화를 통해 사용자 경험을 더욱 향상시킨 점을 강조할 수 있습니다.
