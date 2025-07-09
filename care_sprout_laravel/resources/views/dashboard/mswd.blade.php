@extends('layouts.mswd')

@section('content')
<div class="mswd-dashboard">
    <!-- Header Section -->
    <div class="dashboard-header">
        <h1>Dashboard</h1>
    </div>

    <!-- Search & Filter Section -->
    <div class="search-filter-section">
        <div class="search-container">
            <i class="fas fa-search search-icon"></i>
            <input type="text" id="studentSearch" placeholder="Search students by name, disability, or case number..." class="search-input">
        </div>
        <div class="filter-container">
            <select id="statusFilter" class="filter-select">
                <option value="">All Status</option>
                <option value="pending">Pending</option>
                <option value="review">Under Review</option>
                <option value="approved">Approved</option>
                <option value="rejected">Rejected</option>
            </select>
            <select id="disabilityFilter" class="filter-select">
                <option value="">All Disabilities</option>
                <option value="speech-delay">Speech Delay</option>
                <option value="autism">Autism</option>
                <option value="learning-disability">Learning Disability</option>
                <option value="physical-disability">Physical Disability</option>
                <option value="hearing-impairment">Hearing Impairment</option>
                <option value="visual-impairment">Visual Impairment</option>
            </select>
            <select id="ageFilter" class="filter-select">
                <option value="">All Ages</option>
                <option value="3-5">3-5 years</option>
                <option value="6-8">6-8 years</option>
                <option value="9-12">9-12 years</option>
                <option value="13-18">13-18 years</option>
            </select>
        </div>
    </div>

    <!-- Main Content Area -->
    <div class="main-content-area">
        <!-- Student List Section -->
        <div class="student-list-section">
            <div class="section-header">
                <h2>Student Cases</h2>
                <span class="case-count" id="caseCount">0 cases</span>
            </div>
            <div class="student-list" id="studentList">
                <!-- Student items will be populated dynamically -->
            </div>
        </div>

        <!-- Student Details Section -->
        <div class="student-details-section">
            <div class="section-header">
                <h2>Student Details</h2>
                <button class="close-details" id="closeDetails" style="display: none;">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="student-details-content" id="studentDetails">
                <div class="no-selection">
                    <i class="fas fa-user-circle"></i>
                    <p>Select a student to view details</p>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Student Template (hidden) -->
<template id="studentItemTemplate">
    <div class="student-item" data-student-id="">
        <div class="student-avatar">
            <i class="fas fa-user"></i>
        </div>
        <div class="student-info">
            <div class="student-name"></div>
            <div class="student-details">
                <span class="disability"></span>
                <span class="age"></span>
            </div>
        </div>
        <div class="student-status">
            <span class="status-badge"></span>
        </div>
    </div>
</template>

<!-- Student Details Template (hidden) -->
<template id="studentDetailsTemplate">
    <div class="student-profile">
        <div class="profile-header">
            <div class="profile-avatar">
                <i class="fas fa-user"></i>
            </div>
            <div class="profile-info">
                <h3 class="profile-name"></h3>
                <p class="profile-id"></p>
            </div>
        </div>
        
        <div class="profile-details">
            <div class="detail-row">
                <span class="detail-label">Age:</span>
                <span class="detail-value age-value"></span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Birthday:</span>
                <span class="detail-value birthday-value"></span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Disability:</span>
                <span class="detail-value disability-value"></span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Parent/Guardian:</span>
                <span class="detail-value parent-value"></span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Contact:</span>
                <span class="detail-value contact-value"></span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Status:</span>
                <span class="detail-value status-value"></span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Case Date:</span>
                <span class="detail-value case-date-value"></span>
            </div>
        </div>
        
        <div class="action-buttons">
            <button class="action-btn approve-btn">
                <i class="fas fa-check"></i> Approve
            </button>
            <button class="action-btn reject-btn">
                <i class="fas fa-times"></i> Reject
            </button>
            <button class="action-btn review-btn">
                <i class="fas fa-eye"></i> Review
            </button>
            <button class="action-btn edit-btn">
                <i class="fas fa-edit"></i> Edit
            </button>
        </div>
    </div>
</template>

<script>
// Sample data - in real implementation, this would come from the backend
const sampleStudents = [
    {
        id: 1,
        name: "John Doe",
        age: 6,
        birthday: "May 10, 2019",
        disability: "Speech Delay",
        parent: "Mama Doe",
        contact: "09123456789",
        status: "pending",
        caseDate: "2024-01-15",
        notes: [
            { action: "Case Created", date: "2024-01-15", note: "Initial case submission received" },
            { action: "Under Review", date: "2024-01-16", note: "Documents submitted for review" }
        ]
    },
    {
        id: 2,
        name: "Jane Smith",
        age: 5,
        birthday: "July 22, 2020",
        disability: "Autism",
        parent: "Papa Smith",
        contact: "09876543210",
        status: "approved",
        caseDate: "2024-01-10",
        notes: [
            { action: "Case Created", date: "2024-01-10", note: "Initial case submission received" },
            { action: "Approved", date: "2024-01-12", note: "Case approved after review" }
        ]
    },
    {
        id: 3,
        name: "Mike Johnson",
        age: 8,
        birthday: "March 15, 2017",
        disability: "Learning Disability",
        parent: "Mama Johnson",
        contact: "09112233445",
        status: "review",
        caseDate: "2024-01-18",
        notes: [
            { action: "Case Created", date: "2024-01-18", note: "Initial case submission received" },
            { action: "Under Review", date: "2024-01-19", note: "Additional documents requested" }
        ]
    }
];

let currentStudents = [...sampleStudents];
let selectedStudent = null;

// Initialize dashboard
document.addEventListener('DOMContentLoaded', function() {
    renderStudentList();
    setupEventListeners();
    updateCaseCount();
});

function setupEventListeners() {
    // Search functionality
    document.getElementById('studentSearch').addEventListener('input', filterStudents);
    
    // Filter functionality
    document.getElementById('statusFilter').addEventListener('change', filterStudents);
    document.getElementById('disabilityFilter').addEventListener('change', filterStudents);
    document.getElementById('ageFilter').addEventListener('change', filterStudents);
    
    // Close details button
    document.getElementById('closeDetails').addEventListener('click', closeStudentDetails);
}

function renderStudentList() {
    const studentList = document.getElementById('studentList');
    studentList.innerHTML = '';
    
    currentStudents.forEach(student => {
        const studentItem = createStudentItem(student);
        studentList.appendChild(studentItem);
    });
}

function createStudentItem(student) {
    const template = document.getElementById('studentItemTemplate');
    const clone = template.content.cloneNode(true);
    
    const studentItem = clone.querySelector('.student-item');
    studentItem.setAttribute('data-student-id', student.id);
    
    studentItem.querySelector('.student-name').textContent = student.name;
    studentItem.querySelector('.disability').textContent = student.disability;
    studentItem.querySelector('.age').textContent = `${student.age} years old`;
    
    const statusBadge = studentItem.querySelector('.status-badge');
    statusBadge.textContent = student.status.charAt(0).toUpperCase() + student.status.slice(1);
    statusBadge.className = `status-badge ${student.status}`;
    
    studentItem.addEventListener('click', () => selectStudent(student));
    
    return studentItem;
}

function selectStudent(student) {
    selectedStudent = student;
    
    // Update selected state in list
    document.querySelectorAll('.student-item').forEach(item => {
        item.classList.remove('selected');
    });
    document.querySelector(`[data-student-id="${student.id}"]`).classList.add('selected');
    
    // Show student details
    showStudentDetails(student);
    
    // Show close button
    document.getElementById('closeDetails').style.display = 'block';
}

function showStudentDetails(student) {
    const detailsContainer = document.getElementById('studentDetails');
    const template = document.getElementById('studentDetailsTemplate');
    const clone = template.content.cloneNode(true);
    
    clone.querySelector('.profile-name').textContent = student.name;
    clone.querySelector('.profile-id').textContent = `Case #${student.id}`;
    clone.querySelector('.age-value').textContent = `${student.age} years old`;
    clone.querySelector('.birthday-value').textContent = student.birthday;
    clone.querySelector('.disability-value').textContent = student.disability;
    clone.querySelector('.parent-value').textContent = student.parent;
    clone.querySelector('.contact-value').textContent = student.contact;
    clone.querySelector('.status-value').textContent = student.status.charAt(0).toUpperCase() + student.status.slice(1);
    clone.querySelector('.case-date-value').textContent = new Date(student.caseDate).toLocaleDateString();
    
    // Set status badge color
    const statusValue = clone.querySelector('.status-value');
    statusValue.className = `detail-value status-value ${student.status}`;
    
    // Setup action buttons
    setupActionButtons(clone, student);
    
    detailsContainer.innerHTML = '';
    detailsContainer.appendChild(clone);
}

function setupActionButtons(detailsElement, student) {
    const approveBtn = detailsElement.querySelector('.approve-btn');
    const rejectBtn = detailsElement.querySelector('.reject-btn');
    const reviewBtn = detailsElement.querySelector('.review-btn');
    const editBtn = detailsElement.querySelector('.edit-btn');
    
    // Disable buttons based on current status
    if (student.status === 'approved') {
        approveBtn.disabled = true;
        approveBtn.textContent = 'Approved';
    }
    if (student.status === 'rejected') {
        rejectBtn.disabled = true;
        rejectBtn.textContent = 'Rejected';
    }
    
    approveBtn.addEventListener('click', () => updateStudentStatus(student.id, 'approved'));
    rejectBtn.addEventListener('click', () => updateStudentStatus(student.id, 'rejected'));
    reviewBtn.addEventListener('click', () => updateStudentStatus(student.id, 'review'));
    editBtn.addEventListener('click', () => editStudent(student));
}

function closeStudentDetails() {
    selectedStudent = null;
    
    // Clear selection
    document.querySelectorAll('.student-item').forEach(item => {
        item.classList.remove('selected');
    });
    
    // Reset details view
    document.getElementById('studentDetails').innerHTML = `
        <div class="no-selection">
            <i class="fas fa-user-circle"></i>
            <p>Select a student to view details</p>
        </div>
    `;
    
    // Hide close button
    document.getElementById('closeDetails').style.display = 'none';
}

function filterStudents() {
    const searchTerm = document.getElementById('studentSearch').value.toLowerCase();
    const statusFilter = document.getElementById('statusFilter').value;
    const disabilityFilter = document.getElementById('disabilityFilter').value;
    const ageFilter = document.getElementById('ageFilter').value;
    
    currentStudents = sampleStudents.filter(student => {
        const matchesSearch = student.name.toLowerCase().includes(searchTerm) ||
                            student.disability.toLowerCase().includes(searchTerm) ||
                            student.id.toString().includes(searchTerm);
        
        const matchesStatus = !statusFilter || student.status === statusFilter;
        const matchesDisability = !disabilityFilter || student.disability.toLowerCase().replace(' ', '-') === disabilityFilter;
        
        let matchesAge = true;
        if (ageFilter) {
            const [minAge, maxAge] = ageFilter.split('-').map(Number);
            matchesAge = student.age >= minAge && student.age <= maxAge;
        }
        
        return matchesSearch && matchesStatus && matchesDisability && matchesAge;
    });
    
    renderStudentList();
    updateCaseCount();
}

function updateCaseCount() {
    const count = currentStudents.length;
    document.getElementById('caseCount').textContent = `${count} case${count !== 1 ? 's' : ''}`;
}

function updateStudentStatus(studentId, newStatus) {
    const student = sampleStudents.find(s => s.id === studentId);
    if (student) {
        student.status = newStatus;
        student.notes.push({
            action: newStatus.charAt(0).toUpperCase() + newStatus.slice(1),
            date: new Date().toISOString().split('T')[0],
            note: `Case status updated to ${newStatus}`
        });
        
        // Refresh the view
        if (selectedStudent && selectedStudent.id === studentId) {
            selectStudent(student);
        }
        renderStudentList();
    }
}

function editStudent(student) {
    // This would open an edit modal or redirect to edit page
    alert(`Edit functionality for ${student.name} would be implemented here`);
}
</script>
@endsection 