---
title: "Strategic Career Bifurcation for the DevOps Engineer in the Age of AI"
date: 2025-12-08
description: "An in-depth analysis of how AI is reshaping DevOps work, why ML infrastructure (MLOps) is the highest-leverage specialization, and a practical roadmap for future-proofing your career."
tags: ["devops", "ai", "career", "mlops", "finops", "devsecops"]
---

## **Executive Summary: The AI/DevOps Bifurcation and Strategic Focus**

The future of DevOps is characterized not by outright replacement, but by radical augmentation. Artificial intelligence demonstrates proficiency in *Change Generation*—tasks such as writing boilerplate scripts and drafting configurations. However, AI faces critical limitations in *Change Application*—managing production risk, conducting complex debugging, and architecting robust systems. Consequently, the value proposition of the DevOps engineer is fundamentally shifting away from execution velocity toward **governance, critical judgment, and mastery of specialized, complex infrastructure**.1

The analysis concludes that the most rewarding and resilient career path is **ML Infrastructure Engineering (MLOps)**. This domain presents the highest barrier of technical complexity, offering a natural defense against immediate automation, while simultaneously addressing the fastest-growing sector of the technology market: artificial intelligence. This specialization demands integrating core DevOps proficiencies (Kubernetes, Cloud, IaC) with specialized High-Performance Computing (HPC) knowledge.

A strategic pivot is required: the engineer should cease optimizing automation for generic Software-as-a-Service (SaaS) microservices and begin maximizing expertise in **specialized orchestration, ultra-low latency networking, and dedicated GPU/TPU resource management** across hybrid and bare-metal environments.

## **Part I: The AI Threat Assessment: Automation vs. Augmentation**

### **The Automation Ceiling: Where AI Thrives and Fails (Brutal Honesty)**

The current capabilities of AI mandate a rigorous reassessment of where human engineering effort provides unique, irreplaceable value. Certain routine tasks are highly exposed to augmentation or direct replacement, which effectively raises the minimum performance threshold for entry-level professionals.

Tasks such as generating boilerplate code, writing simple shell scripts, and creating initial drafts of common Infrastructure as Code (IaC), including Ansible playbooks and basic Terraform modules, are now easily replicated and optimized by AI tools.2 This transformation eliminates the repetitive, rote labor that historically served as a critical training ground for junior engineers. Predictive monitoring, automated testing, and general incident response are also moving rapidly under the purview of AI-driven systems.3

However, the transition from configuration generation to reliable production deployment reveals persistent and deep limitations in current AI technology, centered on precision and risk management.

#### **Precision and Configuration Failure**

AI models demonstrate significant difficulty in adhering to the deterministic precision required by configuration languages. Research has shown that large language models (LLMs) often underperform in crucial YAML-based Continuous Integration (CI) tasks. Outputs frequently suffer from critical issues such as missing or renamed steps, misinterpreted descriptive prompts, and the inclusion of unnecessary additions that compromise the *structural and contextual correctness* required for executable CI configurations.5

This limitation exists because configuration files (like YAML or HashiCorp Configuration Language, HCL) are inherently brittle; unlike general application code, even a minor, syntactically correct error can trigger a catastrophic failure or environment drift. The probabilistic, generative nature of AI struggles with the rigid, context-sensitive grammar required for stable infrastructure deployment. Furthermore, LLMs struggle to maintain reliable performance when processing the large context required by extensive modern software repositories, causing performance to degrade as context lengths increase.6 Consequently, the irreplaceable value of the human engineer shifts toward meticulous validation, critical auditing, and ensuring absolute execution stability of infrastructure code, particularly in complex, multi-provider environments using cross-cloud tools like Terraform.7

#### **Inability to Manage Production Risk**

The Software Development Life Cycle (SDLC) involves tasks of fundamentally different risk profiles. AI excels in Design and Development, termed "Change Generation," where the sensitivity to error is low, allowing for cheap, fast iteration. Conversely, AI fails critically in the later phases—Testing, Staging, and Production—termed "Change Application," where the sensitivity escalates from high to critical.1

Critical infrastructure decisions—such as correctly interpreting subtle log anomalies, authorizing a deployment rollback, or enforcing multi-cloud compliance policies—demand complex human judgment, nuanced risk assessment, and detailed contextual knowledge of the business impact. Current predictive AI systems and LLMs cannot reliably perform these critical risk-based tasks, exhibiting a vulnerability to "hallucinations" that generate plausible but fabricated content.8 This profound limitation ensures sustained, high demand for experienced engineers who function primarily as **critical auditors, governance specialists, and risk managers**.1

### **Foundational Resilience: The Transference of Core Skills**

Despite the tectonic shift caused by automation, the core principles and foundational skills of DevOps are not being rendered obsolete. Instead, AI is accelerating the careers of those who successfully adapt by applying core skills to strategically complex domains, such as Site Reliability Engineering (SRE), AIOps, and MLOps.9

The required bedrock competencies for advancement remain constant: deep expertise in major Cloud providers (AWS, Azure, GCP), certified mastery of Kubernetes (CKA, CKAD, and CKS), and proficiency in Infrastructure as Code (IaC). Cloud certifications are the foundation, while Kubernetes certifications provide the practical proof of orchestration capability.10 Terraform certification is the IaC standard, dominating the market with over 15,000 U.S. job postings mentioning it.10 Linux proficiency remains the foundational, evergreen skill upon which all modern cloud and AI systems rely.10

## **Part II: The Three Pillars of Future-Proof Specialization**

The modern DevOps professional must strategically select a specialization path that establishes a high barrier to automation and delivers non-commoditized value. The analysis identifies three highly lucrative and resilient specializations defined by managing strategic imperatives: Risk (DevSecOps), Cost (FinOps), and Complexity (ML Infrastructure).

### **Comparative Market Analysis: DevSecOps, FinOps, and MLOps**

| Specialization | Primary Focus & Strategic Value | Market Growth Trajectory | Average Senior Salary Potential |
| :---- | :---- | :---- | :---- |
| **DevSecOps Engineer** | Risk Management; Proactive security integration; Compliance assurance.11 | High demand, strengthening digital resilience.12 | Very High (Seniors \~$214,500).13 |
| **FinOps Engineer** | Cost Governance; Financial accountability; Optimization (bridging Engineering/Finance).14 | Exponential, driven by $1T+ cloud spend forecast.16 | High (Optimization Engineers).17 |
| **ML Infrastructure Engineer (MLOps)** | Scaling ML/AI models; Distributed computing; Specialized hardware orchestration.18 | Explosive (9.8x growth, 41% CAGR market size).20 | Highest potential (Top earners $163,000+).22 |

#### **DevSecOps: Managing Risk**

This specialization is critical for strengthening an organization's digital resilience and ensuring regulatory compliance.12 DevSecOps focuses on "shifting security left," embedding security testing, vulnerability scanning, and compliance checks early and automating them within CI/CD pipelines.23 This proactive approach ensures that security problems are fixed before expensive dependencies are introduced, reducing the overall cost of remediation and freeing security teams to focus on higher value work.11 Since security is a mandatory function necessary for organizational integrity and regulatory compliance, the demand is stable and high. Senior DevSecOps roles are among the most highly compensated in the field, with senior-level salaries reaching approximately **$214,500** annually.13

#### **FinOps: Managing Cost and Strategy**

FinOps is an operational framework that integrates technology, finance, and business teams to drive financial accountability and maximize the business value derived from cloud investments.14 With the global public cloud market forecast to exceed **$1 trillion by 2030** 16, the need for skilled cost optimization specialists is skyrocketing.

FinOps professionals do not merely cut costs; they hold a strategic position, using infrastructure expertise to influence architectural decisions based on measurable cost savings and business outcomes.17 This field is rapidly evolving to include AI-powered cost optimization and predictive cost modeling.15 By combining core DevOps automation with financial forecasting, FinOps teams ensure money is spent in the most efficient manner, bridging the gap between development speed and financial accountability.15

#### **ML Infrastructure Engineer (MLOps): Managing Complexity**

The path of highest technical specialization is MLOps, which applies DevOps principles to the machine learning lifecycle, optimizing collaboration between data science and operations teams.26 This domain is characterized by explosive growth, identified as an emerging role with a remarkable **9.8x growth** over five years.20 The MLOps market size is projected to grow from $2.19 billion in 2024 to **$16.61 billion by 2030**.21

The compelling case for MLOps is the inherent complexity barrier it presents. Unlike standard software deployment, MLOps requires managing data lineage, model versioning, specialized hardware, and distributed training pipelines. While MLOps roles are currently fewer in volume compared to general DevOps or Data Engineer positions, the required skillset is much harder to acquire, creating a deep technical moat that is highly resistant to generic AI automation.28 The average annual pay for an ML Infrastructure Engineer in the United States is approximately **$127,066**, with top earners reaching up to **$163,000**.22

## **Part III: Deep Dive into AI Workloads: The Path to 'Hero Depth'**

The recommendation to focus on AI workloads centers on their unique demands, which elevate the required technical expertise far beyond the scope of traditional microservices deployment.

### **The Complexity Barrier: MLOps Requires Specialization**

MLOps is fundamentally different from traditional DevOps because the core artifact is a serialized model dependent on dynamic data, not just static application code.18

ML engineers must tackle data challenges that are largely irrelevant in traditional software engineering, specifically those related to data quality, governance, and provenance.30 They are responsible for building scalable systems to collect, process, and store data, and for ensuring reproducibility of models through meticulous control over code, data, and model versioning with lineage tracking.27 This requires engineers to standardize workflows and foster cross-functional collaboration, aligning model inputs, infrastructure needs, and deployment targets early in the lifecycle.31

### **Scaling AI: The HPC Requirement**

Modern AI, particularly in large language models (LLMs) and generative AI, demands a shift from standard cloud elasticity to principles derived from High-Performance Computing (HPC).

Distributed training is mandatory because training a model with 175 billion parameters would require an estimated 288 years on a single NVIDIA V100 GPU, and the scale often exceeds the limits of a single card.32 This requires the adoption of distributed data parallel training, which involves initializing model copies on each device, partitioning the dataset, performing parallel forward passes, and then executing a complex **all-reduce operation** on the gradients to synchronize the models.33 The core technical challenge is therefore not the simple provisioning of graphical processing units (GPUs) but the mastery of **synchronous, ultra-low latency communication** and coordination among these expensive resources.

### **Orchestration and Hardware Mastery in Kubernetes**

Mastering ML infrastructure involves becoming a highly specialized Kubernetes expert who can efficiently extend the control plane to manage specialized hardware.

#### **Device Management and Specialized Schedulers**

Engineers must deploy and manage vendor-specific **Device Plugins** (such as those from NVIDIA or Intel) to advertise specialized resources like GPUs, FPGAs, and high-performance Network Interface Cards (NICs) to the Kubernetes Kubelet.34 This ensures that high-value accelerators are correctly allocated to demanding workloads via the extended resource naming scheme (e.g., nvidia.com/gpu).34

Furthermore, distributed training jobs, orchestrated by systems like Ray or Kubeflow, require **Gang Scheduling**, which ensures that all component pods (workers and parameter servers) start simultaneously to prevent resource waste and slow job completion.36 This specialized scheduling moves Kubernetes from a pod-centric to a workload-centric concept.37 Implementing this requires specialized knowledge of KubeRay/Kubeflow Trainer operators and their use of PodGroupPolicy to enable co-scheduling.38

#### **Bare Metal vs. Cloud Economics**

For major organizations building proprietary "AI Factories," the management of GPU compute cost and performance is a strategic imperative. Bare metal GPU servers offer lower latency and more reliable performance compared to multi-tenant cloud virtual servers because the engineer has exclusive control over the entire physical machine.40

From a financial perspective, long-term, sustained, high-utilization AI workloads are significantly more cost-effective on bare metal, potentially achieving savings of **up to 60 percent** compared to continuous cloud GPU consumption.41 This strong economic driver creates a high-demand niche for ML Infrastructure Engineers skilled in architecting and managing hybrid cloud or on-premises Kubernetes clusters that leverage bare metal infrastructure efficiently.

### **Advanced Networking: The Ultimate Technical Barrier**

The most significant technical barrier, which provides the greatest protection against automation for ML infrastructure roles, is the mastery of high-performance, ultra-low latency networking required for distributed GPU-to-GPU communication.

#### **InfiniBand and RDMA**

Massive AI training requires specialized interconnects such as **NVIDIA Quantum InfiniBand**, engineered to provide the fastest networking performance for extreme-size datasets and highly parallelized algorithms.42 The enabling technology here is **Remote Direct Memory Access (RDMA)**, which allows data transfer directly between the memory of accelerators on different servers without involving the host CPU or operating system kernel.

#### **Kubernetes Integration of RDMA**

Integrating RDMA capabilities (whether via InfiniBand or RoCE) within a Kubernetes cluster requires profound infrastructure expertise. It necessitates using vendor-specific network operators (e.g., Nvidia/Mellanox) to provision SR-IOV secondary interfaces and setting precise NCCL environment variables within the pod specification to ensure the AI workload utilizes the dedicated RDMA interface.44 This specific skillset—integrating specialized hardware, kernel bypass networking, and cluster orchestration—is highly complex, vendor-specific, and requires expertise that AI models cannot easily replicate or automate.

Table: Essential AI Workload Infrastructure Stack

| Technical Domain | Key Challenges & Required Expertise | Core Tools/Technologies |
| :---- | :---- | :---- |
| **Resource Orchestration** | GPU/FPGA allocation; Co-scheduling components (Gang Scheduling); Maximizing GPU utilization. | Kubernetes (Device Plugins), KubeFlow, KubeRay, Native K8s Schedulers.34 |
| **Distributed Training** | Data/Model Parallelism; Fault Tolerance; Minimizing synchronization overhead (All-Reduce). | PyTorch/TensorFlow Distributed, Ray, NCCL.32 |
| **High-Performance Networking** | Ultra-low latency communication; Bypassing OS kernel (RDMA); Large cluster scaling. | InfiniBand, RoCE, NVIDIA Quantum/ConnectX HCAs, RDMA-capable Kubernetes Operators.42 |
| **Model/Data Workflow** | Versioning Models, Data, and Features; Ensuring reproducibility and data lineage. | MLflow, DVC, Feature Stores, Standardized MLOps platforms (Databricks, Kubeflow).27 |

## **Conclusions and Actionable Roadmap**

The advent of AI necessitates a strategy of aggressive specialization for the DevOps engineer. Generic, boilerplate-focused operational tasks are being rapidly commoditized. Maximum career reward and resilience are found by focusing on domains defined by extreme complexity, specifically the ML Infrastructure Engineer role.

### **Strategic Action Plan for Hero Depth**

1. **Reinforce the Core Cloud and Orchestration Foundation:** Professional validation of fundamental skills remains mandatory. Achieving certifications such as the AWS/Azure DevOps Engineer Professional and Kubernetes certifications (CKA, CKS) provides non-negotiable proof of competence.10  
2. **Acquire Data and Modeling Fluency:** The engineer must bridge the historical gap between data science and engineering by developing working proficiency in Python and possessing a foundational understanding of machine learning concepts, including statistical analysis and model evaluation.19  
3. **Master Advanced Kubernetes Extensibility:** Focus technical training on extending the Kubernetes control plane. This includes mastering the use of **Device Plugins** for hardware resources 34 and specialized scheduling techniques, specifically **Gang Scheduling**, by leveraging operators like KubeRay or Kubeflow.37  
4. **Embrace FinOps and Compute Economics:** Develop a strategic understanding of compute cost management. The ability to articulate the cost trade-offs and performance implications of cloud GPUs versus bare metal GPUs is essential for career mobility and demonstrating strategic influence on architectural decisions.41  
5. **Target the Networking Barrier (HPC):** Study InfiniBand, RoCE, and RDMA principles. Building a working, demonstrable Kubernetes AI home lab that showcases the ability to manage these complex, ultra-low latency systems is highly valued by recruiters and provides concrete evidence of specialized skills.9  
6. **Seek Specialized Experience:** Aggressively pursue roles that specifically require experience in distributed training, deployment of large language models (LLMs), or management of specialized hardware (GPUs/TPUs). This focus on complexity is the most effective defense against automation.

#### **Works cited**

1. What AI Can't Do in DevOps (Yet) - DuploCloud, accessed December 8, 2025, `https://duplocloud.com/blog/what-ai-cant-do-in-devops/`  
2. Top AI Trends in DevOps for 2025 - Copilot4DevOps, accessed December 8, 2025, `https://copilot4devops.com/top-ai-trends-in-devops-for-2025/`  
3. Top 12 AI Tools For DevOps in 2025 - Spacelift, accessed December 8, 2025, `https://spacelift.io/blog/ai-devops-tools`  
4. AI-Powered DevOps: The Future of Automation in 2025 | by Yogesh Patil | Medium, accessed December 8, 2025, `https://medium.com/@hitesh-patil/ai-powered-devops-the-future-of-automation-in-2025-76896a046917`  
5. Can LLMs Write CI? A Study on Automatic Generation of GitHub Actions Configurations - arXiv, accessed December 8, 2025, `https://arxiv.org/pdf/2507.17165`  
6. LLMs for Debugging Code - DZone, accessed December 8, 2025, `https://dzone.com/articles/llms-for-debugging-code`  
7. Terraform Infrastructure as Code (IaC) Guide With Examples (2026) - Firefly, accessed December 8, 2025, `https://www.firefly.ai/academy/terraform-iac`  
8. Debugging LLM Failures: A Comprehensive Guide to Robust AI Applications - Medium, accessed December 8, 2025, `https://medium.com/@kuldeep.paul08/debugging-llm-failures-a-comprehensive-guide-to-robust-ai-applications-4d3e07c59df5`  
9. Why DevOps Jobs Will Explode in 2026 (AI Boom) - YouTube, accessed December 8, 2025, `https://www.youtube.com/watch?v=2wMssuJHLJ8&vl=en-US`  
10. Best DevOps Certifications 2025 | Career Roadmap - KodeKloud, accessed December 8, 2025, `https://kodekloud.com/blog/best-devops-certifications-in-2025/`  
11. What is DevSecOps? - IBM, accessed December 8, 2025, `https://www.ibm.com/think/topics/devsecops`  
12. DevOps vs DevSecOps vs MLOps: Careers in IT 2025. - ARDURA Consulting, accessed December 8, 2025, `https://ardura.consulting/our-blog/devops-vs-devsecops-vs-mlops-which-career-path-to-choose-in-2025/`  
13. DevSecOps Salary 2025: How Much Can You Earn? - Dumpsgate, accessed December 8, 2025, `https://dumpsgate.com/devsecops-salary/`  
14. What is Cloud FinOps?, accessed December 8, 2025, `https://cloud.google.com/learn/what-is-finops`  
15. FinOps vs DevOps - Learn the Differences - Pelanor, accessed December 8, 2025, `https://www.pelanor.io/blog/finops-vs-devops-complete-guide`  
16. Why FinOps Jobs Are Booming: A High-Demand Career Path - Holori, accessed December 8, 2025, `https://holori.com/finops-jobs-are-booming/`  
17. How To Start A FinOps Career: Roles, Skills, Jobs, And Growth Paths - CloudZero, accessed December 8, 2025, `https://www.cloudzero.com/blog/how-to-start-finops-career/`  
18. MLOps vs. DevOps: What is the Difference? - phData, accessed December 8, 2025, `https://www.phdata.io/blog/mlops-vs-devops-whats-the-difference/`  
19. What are the key skills and qualifications needed to thrive in the Machine Learning Infrastructure Engineer position and why are they important - ZipRecruiter, accessed December 8, 2025, `https://www.ziprecruiter.com/e/What-are-the-key-skills-and-qualifications-needed-to-thrive-in-the-Machine-Learning-Infrastructure-Engineer-position-and-why-are-they-important`  
20. MLOps Engineers 2025 Skills Salaries & Growth | People In AI, accessed December 8, 2025, `https://www.peopleinai.com/blog/the-job-market-for-mlops-engineers-in-2025`  
21. Global MLOps Jobs 2025: Hiring Trends and Career Outlook - EliteRecruitments, accessed December 8, 2025, `https://eliterecruitments.com/the-rise-of-mlops-jobs-global-hiring-trends-and-future-outlook/`  
22. Salary: Ml Infrastructure Engineer (Dec, 2025) United States - ZipRecruiter, accessed December 8, 2025, `https://www.ziprecruiter.com/Salaries/Ml-Infrastructure-Engineer-Salary`  
23. What is DevSecOps? A Guide to Secure Software Development | OpenText, accessed December 8, 2025, `https://www.opentext.com/what-is/devsecops`  
24. FinOps Framework Overview, accessed December 8, 2025, `https://www.finops.org/framework/`  
25. FinOps vs. DevOps: The Ultimate Guide | nOps, accessed December 8, 2025, `https://www.nops.io/blog/finops-vs-devops/`  
26. MLOps vs DevOps: Key Differences and Similarities | BrowserStack, accessed December 8, 2025, `https://www.browserstack.com/guide/mlops-vs-devops`  
27. MLOps vs DevOps: Essential Differences for Tech Leaders [2025] - Netguru, accessed December 8, 2025, `https://www.netguru.com/blog/mlops-vs-devops`  
28. MLOPs job market: Is MLOps too niche? - Reddit, accessed December 8, 2025, `https://www.reddit.com/r/mlops/comments/1kb57q3/mlops_job_market_is_mlops_too_niche/`  
29. Are Software Engineers in Demand? Data, Trends & Outlook for 2025 | ThirstySprout, accessed December 8, 2025, `https://www.thirstysprout.com/post/are-software-engineers-in-demand`  
30. Machine Learning Engineer: Challenges and Changes Facing the Profession - Dice, accessed December 8, 2025, `https://www.dice.com/career-advice/machine-learning-engineer-challenges-changes-facing-profession`  
31. Top 7 Machine Learning Engineering Challenges (and How to Overcome Them), accessed December 8, 2025, `https://www.credencys.com/blog/machine-learning-engineering-challenges/`  
32. Accelerate MLOps with Distributed Computing for Scalable Machine Learning - Medium, accessed December 8, 2025, `https://medium.com/weles-ai/accelerate-mlops-with-distributed-computing-for-scalable-machine-learning-99a082d5720d`  
33. M30 - Distributed Training - DTU-MLOps, accessed December 8, 2025, `https://skaftenicki.github.io/dtu_mlops/s9_scalable_applications/distributed_training/`  
34. Device Plugins | Kubernetes, accessed December 8, 2025, `https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/device-plugins/`  
35. Device Plugins: The Path to Faster Workloads in Kubernetes* - Intel, accessed December 8, 2025, `https://www.intel.com/content/www/us/en/developer/articles/technical/device-plugins-path-faster-workloads-in-kubernetes.html`  
36. Kubernetes Schedulers for AI & Data use-cases | by Amit Singh Rathore | Medium, accessed December 8, 2025, `https://asrathore08.medium.com/kubernetes-schedulers-for-ai-data-use-cases-79a711444832`  
37. Kubernetes 1.35 Native Gang Scheduling! Complete Demo + Workload API Setup, accessed December 8, 2025, `https://www.youtube.com/watch?v=bD_eQU0GwOw`  
38. Overview | Kubeflow, accessed December 8, 2025, `https://www.kubeflow.org/docs/components/trainer/operator-guides/job-scheduling/overview/`  
39. Ray on Kubernetes — Ray 2.52.1 - Ray Docs, accessed December 8, 2025, `https://docs.ray.io/en/latest/cluster/kubernetes/index.html`  
40. Cloud GPU vs GPU Bare Metal Server Hosting - Liquid Web, accessed December 8, 2025, `https://www.liquidweb.com/gpu/cloud-gpu-vs-bare-metal-server/`  
41. GPU On Bare Metal Servers - RedSwitches, accessed December 8, 2025, `https://www.redswitches.com/blog/gpu-on-bare-metal/`  
42. Networking Solutions for the Era of AI - NVIDIA, accessed December 8, 2025, `https://www.nvidia.com/en-us/networking/`  
43. Accelerated InfiniBand Solutions for HPC - NVIDIA, accessed December 8, 2025, `https://www.nvidia.com/en-us/networking/products/infiniband/`  
44. Deploying multi-node LLM with infiband/ROCE - General - vLLM Forums, accessed December 8, 2025, `https://discuss.vllm.ai/t/deploying-multi-node-llm-with-infiband-roce/1344`  
45. Azure/aks-rdma-infiniband - GitHub, accessed December 8, 2025, `https://github.com/Azure/aks-rdma-infiniband`  
46. Preprocessing large datasets with Ray and GKE | Google Cloud Blog, accessed December 8, 2025, `https://cloud.google.com/blog/products/ai-machine-learning/preprocessing-large-datasets-with-ray-and-gke/`  
47. Top 12 Machine Learning Engineer Skills To Start Your Career | DataCamp, accessed December 8, 2025, `https://www.datacamp.com/blog/machine-learning-engineer-skills`  


